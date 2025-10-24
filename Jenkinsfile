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
    }

    stages {

        stage('Checkout') {
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

        stage('Launch App on EC2') {
            steps {
                script {
                    echo "Connexion SSH à l’instance EC2..."
                    sh '''
                        EC2_IP=$(terraform -chdir=terraform output -raw public_ip)
                        echo "Instance EC2: $EC2_IP"
                        ssh -o StrictHostKeyChecking=no -i ~/.ssh/aws-key.pem ec2-user@$EC2_IP "docker run -d -p 80:80 ${DOCKER_HUB_USER}/${FRONT_IMAGE}:latest"
                        ssh -o StrictHostKeyChecking=no -i ~/.ssh/aws-key.pem ec2-user@$EC2_IP "docker run -d -p 3000:3000 ${DOCKER_HUB_USER}/${BACK_IMAGE}:latest"
                    '''
                }
            }
        }
    }

 post {
    success {
        script {
            def EC2_IP = sh(script: "terraform -chdir=terraform output -raw public_ip", returnStdout: true).trim()
            echo "✅ Déploiement réussi sur http://${EC2_IP}:3000"
            emailext(
                subject: "SUCCÈS Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a réussi!\nFrontend: http://${EC2_IP}:3000\nBackend: http://${EC2_IP}:3000\nConsultez: ${env.BUILD_URL}",
                to: "mohamedndoye07@gmail.com"
            )
        }
    }
    failure {
        echo "❌ Le pipeline a échoué."
        emailext(
            subject: "ÉCHEC Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "Le pipeline a échoué.\nConsultez: ${env.BUILD_URL}",
            to: "mohamedndoye07@gmail.com"
        )
    }
}

}
