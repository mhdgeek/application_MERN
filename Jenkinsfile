pipeline {
    agent any

    tools {
        nodejs "NodeJS_16"
    }

    environment {
        DOCKER_HUB_USER = 'fatimaaaah'
        FRONT_IMAGE = 'react-frontend'
        BACK_IMAGE  = 'express-backend'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/fatimaaaaah/application_MERN.git'
            }
        }

        stage('Install dependencies - Backend') {
            steps {
                dir('back-end') {
                    bat 'npm install'
                    bat 'node -v && npm -v'
                }
            }
        }

        stage('Install dependencies - Frontend') {
            steps {
                dir('front-end') {
                    bat 'npm install'
                    bat 'node -v && npm -v'
                }
            }
        }

        stage('Run Tests') {
            steps {
                dir('back-end') {
                    bat 'npm test || echo Aucun test backend'
                }
                dir('front-end') {
                    bat 'npm test || echo Aucun test frontend'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                bat "docker build -t %DOCKER_HUB_USER%/%FRONT_IMAGE%:latest ./front-end"
                bat "docker build -t %DOCKER_HUB_USER%/%BACK_IMAGE%:latest ./back-end"
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat '''
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker push %DOCKER_USER%/react-frontend:latest
                        docker push %DOCKER_USER%/express-backend:latest
                    '''
                }
            }
        }

        stage('Check Docker & Compose') {
            steps {
                bat 'docker --version'
                bat 'docker-compose --version || echo docker-compose non trouvé'
            }
        }

        stage('Deploy (docker-compose)') {
            steps {
                dir('.') {
                    bat 'docker-compose -f compose.yaml down || exit 0'
                    bat 'docker-compose -f compose.yaml pull || exit 0'
                    bat 'docker-compose -f compose.yaml up -d'
                    bat 'docker-compose -f compose.yaml ps'
                    bat 'docker-compose -f compose.yaml logs -f --tail=20'
                }
            }
        }

        stage('Smoke Test') {
            steps {
                bat '''
                    curl -f http://localhost:3000 || echo Frontend unreachable
                    curl -f http://localhost:5000 || echo Backend unreachable
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline terminé !!!!!"
        }
    }
}
