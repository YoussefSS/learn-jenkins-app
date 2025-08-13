pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'c93acf51-8803-419f-920a-f633fb067e19' // Netlify checks for this environment variable, so must be spelled correctly
        NETLIFY_AUTH_TOKEN = credentials('netlify-token') // Netlify also checks this
        REACT_APP_VERSION = '1.0.$BUILD_ID"'
    }

    stages {
        stage('Build') {
            agent {
                docker { // we need docker to have a config with npm
                    image 'node:18-alpine'
                    reuseNode true // to use the same workspace as stages not using docker
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci // This is use instead of 'npm install' for CI servers
                    npm run build
                    ls -la
                '''
            }
        }

        stage('Tests') {
            parallel {
                stage('Unit Test') {
                    // We are using npm test, so we need a container with an npm image
                    agent {
                        docker { 
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml' // path to the junit results
                        }
                    }
                }

                stage('End-To-End Tests') {
                    // We are using npm test, so we need a container with an npm image
                    agent {
                        docker { 
                            image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                            reuseNode true
                        }
                    }
                    steps {
                        // playwright is an external tool to run E2E tests
                        // We are installing serve locally (to the project) and running it
                        // The & after serve means run the server in the background and do not block the execution of the rest of the commands
                        // We also wait for 10 seconds for the server to start
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report Local', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }              
            }
        }

        stage('Deploy staging') {
            // We are using npm test, so we need a container with an npm image
            agent {
                docker { 
                    image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "STAGING_URL_TO_BE_SET"
            }
            steps {
                sh '''
                    npm install netlify-cli@20.1.1 node-jq
                    node_modules/.bin/netlify --version
                    echo "Deploying to staging, Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json)
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report Staging', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }   

        stage('Deploy prod') {
            // We are using npm test, so we need a container with an npm image
            agent {
                docker { 
                    image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://bespoke-swan-99a41f.netlify.app'
            }
            steps {
                sh '''
                    node --version
                    echo "Small change"
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to production, Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report Production', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }        
    }
}
