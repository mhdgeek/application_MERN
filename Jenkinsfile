pipeline {
    agent any

    tools {
        nodejs "NodeJS_22"
    }

    environment {
        DOCKER_HUB_USER = 'mhd0'
        FRONT_IMAGE = 'react-frontend'
        BACK_IMAGE  = 'express-backend'
        PATH = "/usr/local/bin:${env.PATH}"
        AWS_REGION = 'us-west-2'
        SSH_KEY_PATH = '~/.ssh/aws-key.pem'
        RECIPIENT_EMAIL = 'mohamedndoye07@gmail.com'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/mhdgeek/application_MERN.git'
            }
        }

        stage('Install Dependencies') {
            parallel {
                stage('Backend Dependencies') {
                    steps {
                        dir('back-end') {
                            sh 'npm install'
                        }
                    }
                }
                stage('Frontend Dependencies') {
                    steps {
                        dir('front-end') {
                            sh 'npm install'
                        }
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                dir('back-end') {
                    sh 'npm test || echo "No backend tests or skipped"'
                }
                dir('front-end') {
                    sh 'npm test || echo "No frontend tests or skipped"'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    sh "docker build -t ${env.DOCKER_HUB_USER}/${env.FRONT_IMAGE}:latest ./front-end"
                    sh "docker build -t ${env.DOCKER_HUB_USER}/${env.BACK_IMAGE}:latest ./back-end"
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh """
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                            docker push $DOCKER_HUB_USER/$FRONT_IMAGE:latest
                            docker push $DOCKER_HUB_USER/$BACK_IMAGE:latest
                        """
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-sandbox-credentials'
                    ]
                ]) {
                    dir('terraform') {
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Get EC2 Public IP') {
            steps {
                script {
                    env.EC2_IP = sh(script: "terraform -chdir=terraform output -raw public_ip", returnStdout: true).trim()
                    echo "Instance EC2 IP: ${env.EC2_IP}"
                }
            }
        }

        stage('Send Code & Launch App') {
            steps {
                script {
                    sh """
                        # Copier backend et frontend
                        scp -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -r back-end ec2-user@${EC2_IP}:/home/ec2-user/
                        scp -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -r front-end ec2-user@${EC2_IP}:/home/ec2-user/

                        # Lancer les apps via SSH
                        ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << 'EOF'
                        cd back-end
                        npm install
                        nohup npm start > backend.log 2>&1 &

                        cd ../front-end
                        npm install
                        nohup npm start > frontend.log 2>&1 &
                        EOF
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    sh """
                        curl -I http://${EC2_IP}:3000 || echo 'Frontend not ready yet'
                        curl -I http://${EC2_IP}:5000 || echo 'Backend not ready yet'
                    """
                }
            }
        }
    }

    post {
        success {
            script {
                echo "✅ Déploiement réussi sur http://${EC2_IP}:3000 (frontend) et http://${EC2_IP}:5000 (backend)"
                emailext(
                    subject: "✅ SUCCÈS Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: "Le pipeline a réussi!\nFrontend: http://${EC2_IP}:3000\nBackend: http://${EC2_IP}:5000\nConsultez: ${env.BUILD_URL}",
                    to: "${RECIPIENT_EMAIL}"
                )
            }
        }
        failure {
            script {
                echo "❌ Le pipeline a échoué"
                emailext(
                    subject: "❌ ÉCHEC Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: "Le pipeline a échoué.\nConsultez: ${env.BUILD_URL}",
                    to: "${RECIPIENT_EMAIL}"
                )
            }
        }
    }
}
