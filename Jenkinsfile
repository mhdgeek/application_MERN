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
<<<<<<< HEAD
        KUBECONFIG = "/Users/mhd/.kube/config"
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
=======
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
>>>>>>> 36a6b06 (ajout de terraform)
                }
            }
        }

<<<<<<< HEAD
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

=======
>>>>>>> 36a6b06 (ajout de terraform)
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
<<<<<<< HEAD
                            docker tag $DOCKER_HUB_USER/$FRONT_IMAGE:latest $DOCKER_HUB_USER/$FRONT_IMAGE:\$BUILD_NUMBER
                            docker tag $DOCKER_HUB_USER/$BACK_IMAGE:latest $DOCKER_HUB_USER/$BACK_IMAGE:\$BUILD_NUMBER
                            unset HTTP_PROXY
                            unset HTTPS_PROXY
                            unset NO_PROXY
                            docker push $DOCKER_HUB_USER/$FRONT_IMAGE:latest
                            docker push $DOCKER_HUB_USER/$FRONT_IMAGE:\$BUILD_NUMBER
                            docker push $DOCKER_HUB_USER/$BACK_IMAGE:latest
                            docker push $DOCKER_HUB_USER/$BACK_IMAGE:\$BUILD_NUMBER
=======
                            docker push $DOCKER_HUB_USER/$FRONT_IMAGE:latest
                            docker push $DOCKER_HUB_USER/$BACK_IMAGE:latest
>>>>>>> 36a6b06 (ajout de terraform)
                        """
                    }
                }
            }
        }

<<<<<<< HEAD
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "🚀 Déploiement MongoDB..."
                    sh 'kubectl apply -f k8s/mongodb-deployment.yaml'

                    echo "🚀 Déploiement Backend..."
                    sh 'kubectl apply -f k8s/backend-deployment.yaml'
                    sh 'kubectl apply -f k8s/backend-service.yaml'

                    echo "🚀 Déploiement Frontend..."
                    sh 'kubectl apply -f k8s/frontend-deployment.yaml'
                    sh 'kubectl apply -f k8s/frontend-service.yaml'

                    echo "⏳ Attente des déploiements..."
                    sh '''
                        kubectl rollout status deployment/backend-deployment --timeout=300s
                        kubectl rollout status deployment/frontend-deployment --timeout=300s
                    '''
=======
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
>>>>>>> 36a6b06 (ajout de terraform)
                }
            }
        }

<<<<<<< HEAD
        stage('Health Check & Smoke Tests') {
            steps {
                script {
                    echo "🔍 Vérification des pods..."
                    sh '''
                        kubectl get pods
                        kubectl get services
                    '''
                }
            }
        }

        stage('Update Kubernetes Images') {
            steps {
                script {
                    sh """
                        kubectl set image deployment/backend-deployment backend=$DOCKER_HUB_USER/$BACK_IMAGE:\$BUILD_NUMBER
                        kubectl set image deployment/frontend-deployment frontend=$DOCKER_HUB_USER/$FRONT_IMAGE:\$BUILD_NUMBER
                        kubectl rollout status deployment/backend-deployment --timeout=300s
                        kubectl rollout status deployment/frontend-deployment --timeout=300s
                    """
=======
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
>>>>>>> 36a6b06 (ajout de terraform)
                }
            }
        }
    }

    post {
        success {
<<<<<<< HEAD
            script {
                frontendUrl = sh(script: 'minikube service frontend-service --url', returnStdout: true).trim()
                backendUrl = sh(script: 'minikube service backend-service --url', returnStdout: true).trim()
                echo "Frontend: ${frontendUrl}"
                echo "Backend: ${backendUrl}"
                emailext(
                    subject: "SUCCÈS Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: "Le pipeline a réussi!\nFrontend: ${frontendUrl}\nBackend: ${backendUrl}\nConsultez: ${env.BUILD_URL}",
                    to: "mohamedndoye07@gmail.com"
                )
            }
        }
        failure {
        echo "❌ Le déploiement a échoué."
        emailext(
            subject: "ÉCHEC Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "Le pipeline a échoué.\nConsultez: ${env.BUILD_URL}",
            to: "mohamedndoye07@gmail.com"
        )
    }
}
}
=======
            echo "✅ Déploiement réussi sur AWS EC2 !"
        }
        failure {
            echo "❌ Le pipeline a échoué."
        }
    }
}

>>>>>>> 36a6b06 (ajout de terraform)
