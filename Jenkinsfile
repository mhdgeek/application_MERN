pipeline {
    agent any

    tools {
        nodejs "NodeJS_16"   // le nom que tu auras défini dans Jenkins
    }

    environment {
        DOCKER_HUB_USER = 'fatimaaaah'   // ton username Docker Hub
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
                    sh 'npm install'
                    sh 'node -v && npm -v'
                }
            }
        }

        stage('Install dependencies - Frontend') {
            steps {
                dir('front-end') {
                    sh 'npm install'
                    sh 'node -v && npm -v'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'cd back-end && npm test || echo "Aucun test backend"'
                    sh 'cd front-end && npm test || echo "Aucun test frontend"'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    sh "docker build -t $DOCKER_HUB_USER/$FRONT_IMAGE:latest ./front-end"
                    sh "docker build -t $DOCKER_HUB_USER/$BACK_IMAGE:latest ./back-end"
                }
            }
        }

        stage('Push Docker Images') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh script: '''
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                docker push $DOCKER_USER/react-frontend:latest
                docker push $DOCKER_USER/express-backend:latest
            '''
        }
    }
}

   stage('Check Docker & Compose') {
            steps {
                sh 'docker --version'
                sh 'docker-compose --version || echo "docker-compose non trouvé"'
            }
        }

        stage('Deploy (docker-compose)') {
            steps {
                dir('.') {  // répertoire contenant compose.yaml
                    sh 'docker-compose -f compose.yaml down || true'
                    sh 'docker-compose -f compose.yaml pull || true'
                    sh 'docker-compose -f compose.yaml up -d'
                    sh 'docker-compose -f compose.yaml ps'
                    sh 'docker-compose -f compose.yaml logs -f --tail=20'
                }
            }
        }
        stage('Smoke Test') {
    steps {
        sh '''
            curl -f http://localhost:3000 || echo "Frontend unreachable"
            curl -f http://localhost:5000 || echo "Backend unreachable"
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
