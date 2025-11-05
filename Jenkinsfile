pipeline {
    agent any

    tools {
        maven 'maven3.9.11'
    }

    environment {
        REMOTE_HOST = "10.211.55.4"
        REMOTE_USER = "xz"
        REGISTRY = "lessIsMore365/myapp"
        IMAGE_TAG = "latest"
        DEPLOY_NS = "cicd"
    }

    stages {
        stage('Build Jar') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Deploy Remotely') {
            steps {
                sshagent(['k8s-ssh']) {
                    sh '''
                        # 上传 jar 包和 Dockerfile
                        scp -o StrictHostKeyChecking=no target/*.jar Dockerfile ${REMOTE_USER}@${REMOTE_HOST}:/home/xz/

                        # 在远程主机上构建镜像、推送、更新 K8s
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                            docker build -t ${REGISTRY}:${IMAGE_TAG} /home/xz
                            docker push ${REGISTRY}:${IMAGE_TAG}
                            kubectl -n ${DEPLOY_NS} set image deployment/myapp myapp=${REGISTRY}:${IMAGE_TAG} --record
                            kubectl -n ${DEPLOY_NS} rollout status deployment/myapp
                        "
                    '''
                }
            }
        }
    }
}
