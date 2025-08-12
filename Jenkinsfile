pipeline {
    agent any

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

        stage('Test') {
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
            
        }

        stage('End-To-End Tests') {
            // We are using npm test, so we need a container with an npm image
            agent {
                docker { 
                    image 'mcr.microsoft.com/playwright:v1.54.0-noble' // copied from https://playwright.dev/docs/docker
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
                    npx playwright test
                '''
            }
            
        }
    }

    post {
        always {
            junit 'test-results/junit.xml' // path to the junit results
        }
    }
}
