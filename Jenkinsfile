pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        DOCKER_USER = credentials('docker-username')
        DOCKER_PASS = credentials('docker-password')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/mhdgeek/application_MERN.git', branch: 'main'
            }
        }

        stage('Install Dependencies') {
            parallel {
                stage('Backend') {
                    steps {
                        dir('back-end') {
                            sh 'npm install'
                        }
                    }
                }
                stage('Frontend') {
                    steps {
                        dir('front-end') {
                            sh 'npm install'
                        }
                    }
                }
            }
        }

        stage('Run Tests') {
            parallel {
                stage('Backend Tests') {
                    steps {
                        dir('back-end') {
                            sh 'npm test'
                        }
                    }
                }
                stage('Frontend Tests') {
                    steps {
                        dir('front-end') {
                            sh 'npm test'
                        }
                    }
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Backend Docker') {
                    steps {
                        dir('back-end') {
                            sh 'docker build -t mhd0/express-backend:latest .'
                        }
                    }
                }
                stage('Frontend Docker') {
                    steps {
                        dir('front-end') {
                            sh 'docker build -t mhd0/react-frontend:latest .'
                        }
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push mhd0/react-frontend:latest'
                    sh 'docker push mhd0/express-backend:latest'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([file(credentialsId: 'aws-key', variable: 'KEY_FILE')]) {
                    dir('terraform') {
                        sh 'terraform init'
                        sh "terraform apply -auto-approve -var \"private_key=${KEY_FILE}\""
                    }
                }
            }
        }
    }

    post {
        success {
            emailext to: 'mohamedndoye07@gmail.com',
                     subject: "Pipeline Success: MERN App",
                     body: "Le pipeline Jenkins s'est exécuté avec succès."
        }
        failure {
            emailext to: 'mohamedndoye07@gmail.com',
                     subject: "Pipeline Failed: MERN App",
                     body: "Le pipeline Jenkins a échoué. Vérifiez les logs."
        }
    }
}
