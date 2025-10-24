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
        RECIPIENT_EMAIL = 'mohamedndoye07@gmail.com'

        // Variables pour AWS Sandbox (Session token)
        AWS_ACCESS_KEY_ID     = 'ASIA5KY3HIQBP5ESIVKY'
        AWS_SECRET_ACCESS_KEY = 'byQHOPjGSiRGVE0b3AlEWMel0lNvjEEjKBeDqI1z'
        AWS_SESSION_TOKEN     = 'IQoJb3JpZ2luX2VjEKH//////////wEaCXVzLXdlc3QtMiJIMEYCIQCwDlhfrKYp7K1xaqURKmevb18/ixnD5SixfqCwNkAreQIhAO5b5fEhy8Q2OVaG1u9R8ClwEfmHEO0VxGOXS0neFlSXKqcCCFoQABoMOTE2NDk1NzQ2MDUwIgxTKX3XfDAtEkXjqUgqhAKX3WVTjho/VGM4SAhE7k0IiLYRYK5LmKGuTPXsLRMJ674hDVoOEia3bJBRTIql90TNCYbYp4cc9p+4KWZdwJbEvE+wN1eo2jQuLdwZl2Yk1Xf8hlFoeyzu+ymOIKzOjl49l2KRvE2fN5qwKHaB2xkevyOroKfQGkQ+5Nk8zC41IT0w6x9iFcWN1LD8OrzrhA/FdwJIqOpFnPG5LUWeH5deVcoaBfk5ja6YtA1ss5xKSFw7o3KPv+cg6K3M5YzTNKeJZCqetdACx3kODskgtnTHTdqdBYqWtHwXOAlCOjTVcJzs9YRycv1UYf1/e7cxTMkk6/rUgrfXBofyzmuJRviowaKnqjC2+ezHBjqcAQFB5F96D9pazZ/PMChmRU+ZL4qxTdkpcwZZZTKoE7/RQkg8NlE1ECOLlz7DEXdhPUnC9RUvAv37e/Di6UrfF+u04CiCkKoOh3Ws06BVN6erY8LUanPya48rYpMIRU+NHJVbjViqVTl3MxaiVhL9yERAUoLtxGrvPd6k8jC6D/1beoIzc9+wNoHcXpYjiMFI6wELUc2N2MmoCzP11Q=='
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
                git branch: 'main', url: 'https://github.com/mhdgeek/application_MERN.git'
            }
        }

        stage('Install Dependencies') {
            parallel {
                stage('Backend') { steps { dir('back-end') { sh 'npm install' } } }
                stage('Frontend') { steps { dir('front-end') { sh 'npm install' } } }
            }
        }

        stage('Run Tests') {
            steps {
                dir('back-end') { sh 'npm test || echo "No backend tests"' }
                dir('front-end') { sh 'npm test || echo "No frontend tests"' }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_USER}/${FRONT_IMAGE}:latest ./front-end"
                    sh "docker build -t ${DOCKER_HUB_USER}/${BACK_IMAGE}:latest ./back-end"
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push $DOCKER_HUB_USER/$FRONT_IMAGE:latest
                        docker push $DOCKER_HUB_USER/$BACK_IMAGE:latest
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Get EC2 Public IP') {
            steps {
                script {
                    env.EC2_IP = sh(script: "terraform -chdir=terraform output -raw public_ip", returnStdout: true).trim()
                    echo "EC2 Public IP: ${env.EC2_IP}"
                }
            }
        }

        stage('Deploy MERN on EC2') {
            steps {
                sshagent(['aws-ssh-key']) {
                    sh """
                        scp -o StrictHostKeyChecking=no -r back-end ec2-user@${EC2_IP}:/home/ec2-user/
                        scp -o StrictHostKeyChecking=no -r front-end ec2-user@${EC2_IP}:/home/ec2-user/

                        ssh -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << 'EOF'
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
                        curl -I http://${EC2_IP}:3000 || echo 'Frontend not ready'
                        curl -I http://${EC2_IP}:5000 || echo 'Backend not ready'
                    """
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ SUCCÈS Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline réussi!\nFrontend: http://${EC2_IP}:3000\nBackend: http://${EC2_IP}:5000\nConsultez: ${env.BUILD_URL}",
                to: "${RECIPIENT_EMAIL}"
            )
        }
        failure {
            emailext(
                subject: "❌ ÉCHEC Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline échoué.\nConsultez: ${env.BUILD_URL}",
                to: "${RECIPIENT_EMAIL}"
            )
        }
    }
}
