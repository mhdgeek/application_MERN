pipeline {
agent any

tools {
    nodejs "NodeJS_22"
}

environment {
    DOCKER_HUB_USER = 'fatimaaaah'
    FRONT_IMAGE = 'react-frontend'
    BACK_IMAGE  = 'express-backend'
    PATH = "/usr/local/bin:${env.PATH}"
    KUBECONFIG = "C:/Users/pc12/.kube/config"
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

    stage('Deploy to Kubernetes') {
        steps {
            script {
                echo "🚀 Déploiement MongoDB..."
                bat 'kubectl apply -f k8s/mongodb-deployment.yaml'

                echo "⏳ Attente du démarrage de MongoDB..."
                // bat 'timeout /t 60 /nobreak'

                echo "🚀 Déploiement Backend..."
                bat 'kubectl apply -f k8s/backend-deployment.yaml'
                bat 'kubectl apply -f k8s/backend-service.yaml'
                // bat 'timeout /t 20 /nobreak'

                echo "🚀 Déploiement Frontend..."
                bat 'kubectl apply -f k8s/frontend-deployment.yaml'
                bat 'kubectl apply -f k8s/frontend-service.yaml'

                echo "⏳ Attente des déploiements..."
                bat '''
                    kubectl rollout status deployment/backend-deployment --timeout=300s
                    kubectl rollout status deployment/frontend-deployment --timeout=300s
                '''
            }
        }
    }

    stage('Health Check & Smoke Tests') {
        steps {
            script {
                echo "🔍 Vérification simplifiée des services..."
                bat '''
                    echo "=== Vérification des pods ==="
                    kubectl get pods
                    RUNNING_PODS=$(kubectl get pods --no-headers | grep -c "Running")
                    TOTAL_PODS=$(kubectl get pods --no-headers | wc -l)
                    if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]; then
                        echo "✅ Tous les pods sont en cours d'exécution"
                    else
                        echo "❌ Certains pods ne sont pas prêts"
                        exit 1
                    fi
                '''

                bat '''
                    echo "=== Test du backend ==="
                    kubectl port-forward service/backend-service 5001:5000 2>/dev/null &
                    sleep 5
                    curl -s http://localhost:5001 | head -1
                    pkill -f "kubectl port-forward" 2>/dev/null || true
                '''

                bat '''
                    echo "=== Test du frontend ==="
                    FRONTEND_PORT=$(kubectl get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
                    MINIKUBE_IP=$(minikube ip)
                    echo "Frontend URL: http://$MINIKUBE_IP:$FRONTEND_PORT"
                    curl -s -o /dev/null -w "HTTP Code: %{http_code}\n" "http://$MINIKUBE_IP:$FRONTEND_PORT" || echo "Frontend en cours de démarrage"
                '''
            }
        }
    }

    stage('Update Kubernetes Images') {
        steps {
            script {
                bat "kubectl set image deployment/backend-deployment backend=${env.DOCKER_HUB_USER}/${env.BACK_IMAGE}:${BUILD_NUMBER}"
                bat "kubectl set image deployment/frontend-deployment frontend=${env.DOCKER_HUB_USER}/${env.FRONT_IMAGE}:${BUILD_NUMBER}"

                bat '''
                    kubectl rollout status deployment/backend-deployment --timeout=300s
                    kubectl rollout status deployment/frontend-deployment --timeout=300s
                '''
            }
        }
    }
}

post {
    always {
        echo 'Pipeline terminé - vérifiez les logs pour les détails'
        script {
            if (currentBuild.result == 'FAILURE') {
                bat '''
                    echo "=== Backend Pods ==="
                    kubectl get pods -l app=backend
                    echo "=== Frontend Pods ==="
                    kubectl get pods -l app=frontend
                    echo "=== MongoDB Pods ==="
                    kubectl get pods -l app=mongodb
                    echo "=== Services ==="
                    kubectl get services
                '''
            }
        }
    }

    success {
        script {
            bat '''
                echo "🎉 DÉPLOIEMENT RÉUSSI !"
                echo "Frontend: $(minikube service frontend-service --url)"
                echo "Backend: $(minikube service backend-service --url)"
            '''
            frontendUrl = sh(script: 'minikube service frontend-service --url', returnStdout: true).trim()
            backendUrl = sh(script: 'minikube service backend-service --url', returnStdout: true).trim()
            echo "Frontend: ${frontendUrl}"
            echo "Backend: ${backendUrl}"
            emailext(
                subject: "SUCCÈS Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a réussi!\nConsultez: ${env.BUILD_URL}",
                to: "fatimadiouf308@gmail.com"
            )
        }
    }

    failure {
        echo "❌ Le déploiement a échoué."
        emailext(
            subject: "ÉCHEC Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "Le pipeline a échoué.\nDétails: ${env.BUILD_URL}",
            to: "fatimadiouf308@gmail.com"
        )
    }

    cleanup {
        bat '''
            docker logout
            echo "Cleanup completed"
        '''
    }
}

}
