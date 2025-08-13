pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'c93acf51-8803-419f-920a-f633fb067e19' // Netlify checks for this environment variable, so must be spelled correctly
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
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }

                stage('Deploy') {
                    // We are using npm commands, so we need a container with an npm image
                    agent {
                        docker { 
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        // Adding netlify locally, not globally to prevent access issues. This can be skipped by adding netlify to the package.json files
                        sh '''
                            npm install netlify-cli@20.1.1
                            node_modules/.bin/netlify --version
                            echo "Deploying to Site ID: $NETLIFY_SITE_ID"
                        '''
                    }
                }
            }
        }

        
    }
}
