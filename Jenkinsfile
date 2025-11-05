pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/yourname/yourproject.git'
            }
        }

        stage('Build on remote VM') {
            steps {
                sshagent(['your-ssh-credential-id']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no xz@192.168.56.10 "
                            cd ~/yourproject &&
                            docker build -t yourapp:latest . &&
                            docker tag yourapp:latest your-registry/yourapp:latest &&
                            docker push your-registry/yourapp:latest
                        "
                    '''
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                sshagent(['your-ssh-credential-id']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no xz@10.211.55.4"
                            kubectl set image deployment/your-deployment app=your-registry/yourapp:latest -n your-namespace &&
                            kubectl rollout status deployment/your-deployment -n your-namespace
                        "
                    '''
                }
            }
        }
    }
}
