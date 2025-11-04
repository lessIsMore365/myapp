pipeline {
    agent any

    environment {
        APP_NAME = "myapp"
        IMAGE_TAG = "latest"
        IMAGE = "myregistry/${APP_NAME}:${IMAGE_TAG}"
        KUBE_NAMESPACE = "cicd"
        DEPLOY_FILE = "deployment.yaml"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/myapp.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE} .'
            }
        }

        stage('Push Image (Optional)') {
            when {
                expression { return false } // 暂时不推 Harbor，可改成 true + docker push
            }
            steps {
                sh 'docker push ${IMAGE}'
            }
        }

        stage('Deploy to K8s') {
            steps {
                sh '''
                kubectl -n ${KUBE_NAMESPACE} apply -f ${DEPLOY_FILE}
                kubectl -n ${KUBE_NAMESPACE} rollout restart deployment/${APP_NAME}
                '''
            }
        }
    }
}
