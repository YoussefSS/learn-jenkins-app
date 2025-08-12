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
                // Test if the file exists, and run the project-specific tests
                sh '''
                    test -f build/index.html
                    npm test
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
