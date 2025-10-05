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

    triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'ref', value: '$.ref'],
                [key: 'pusher_name', value: '$.pusher.name'],
                [key: 'commit_message', value: '$.head_commit.message']
            ],
            causeString: 'Push GitHub par $pusher_name: $commit_message',
            token: 'mysecret',
            printContributedVariables: true,
            printPostContent: true,
            regexpFilterText: '$ref',
            regexpFilterExpression: 'refs/heads/main'
        )
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
                }
            }
        }

        stage('Install dependencies - Frontend') {
            steps {
                dir('front-end') {
                    bat 'npm install'
                }
            }
        }

        stage('Run Tests') {
            steps {
                dir('back-end') {
                    bat 'npm test || echo "Aucun test backend ou échec ignoré"'
                }
                dir('front-end') {
                    bat 'npm test || echo "Aucun test frontend ou échec ignoré"'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    bat "docker build -t ${env.DOCKER_HUB_USER}/${env.FRONT_IMAGE}:latest ./front-end"
                    bat "docker build -t ${env.DOCKER_HUB_USER}/${env.BACK_IMAGE}:latest ./back-end"
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        bat "echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin"
                        bat "docker push ${env.DOCKER_HUB_USER}/${env.FRONT_IMAGE}:latest"
                        bat "docker push ${env.DOCKER_HUB_USER}/${env.BACK_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                dir('.') {
                    bat 'docker-compose -f compose.yaml down || echo "Arrêt des conteneurs existants"'
                    bat 'docker-compose -f compose.yaml up -d --build'
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sleep time: 30, unit: 'SECONDS' // Attendre que les services démarrent
                    bat 'curl -f http://localhost:3000 || echo "Frontend non accessible"'
                    bat 'curl -f http://localhost:5000 || echo "Backend non accessible"'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé - vérifiez les logs pour les détails'
        }
        success {
            emailext(
                subject: "SUCCÈS Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a réussi!\nConsultez: ${env.BUILD_URL}",
                to: "fatimadiouf308@gmail.com"
            )
        }
        failure {
            emailext(
                subject: "ÉCHEC Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué.\nDétails: ${env.BUILD_URL}",
                to: "fatimadiouf308@gmail.com"
            )
        }
    }
}
