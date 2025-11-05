pipeline {
    agent any

    environment {
        REGISTRY = "yourname/myapp"      // Docker Hub 仓库名
        IMAGE_TAG = "latest"
        DEPLOY_NS = "cicd"
        KUBECONFIG = "/home/xz/.kube/config"   // Jenkins 连接虚机后，指向 K8s 配置文件
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/yourname/myapp.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $REGISTRY:$IMAGE_TAG .'
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $REGISTRY:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sshagent(['k8s-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no xz@your-k8s-ip "
                            kubectl set image deployment/myapp myapp=$REGISTRY:$IMAGE_TAG -n $DEPLOY_NS
                            kubectl rollout status deployment/myapp -n $DEPLOY_NS
                        "
                    '''
                }
            }
        }
    }
}
