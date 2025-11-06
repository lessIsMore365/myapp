pipeline {
    agent any

    tools {
        maven 'maven3.9.11'
    }

    environment {
        REMOTE_HOST = "10.211.55.4"                 // 你的远程主机
        REMOTE_USER = "xz"                          // SSH 用户
        REGISTRY = "192.168.3.41:8080/myapp/myapp"  // Harbor 仓库地址 + 项目名 + 镜像名
        IMAGE_TAG = "latest"                        // 镜像标签
        DEPLOY_NS = "cicd"                          // K8s 命名空间
    }

    stages {
        stage('Build Jar') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Deploy Remotely') {
            steps {
                sshagent(['vm-ssh-key']) {   // 这是 Jenkins 里的 SSH 凭据 ID
                    sh '''
                        # 上传 jar 包和 Dockerfile
                        scp -o StrictHostKeyChecking=no target/*.jar Dockerfile ${REMOTE_USER}@${REMOTE_HOST}:/home/xz/

                        # 远程执行构建、推送、更新部署
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                            echo '==== 登录 Harbor ===='
                            echo 'Harbor 登录中...'
                            docker login 192.168.3.41:8080 -u admin -p 你的Harbor密码

                            echo '==== 构建并推送镜像 ===='
                            docker build -t ${REGISTRY}:${IMAGE_TAG} /home/xz
                            docker push ${REGISTRY}:${IMAGE_TAG}

                            echo '==== 更新 K8s 部署 ===='
                            kubectl -n ${DEPLOY_NS} set image deployment/myapp myapp=${REGISTRY}:${IMAGE_TAG} --record
                            kubectl -n ${DEPLOY_NS} rollout status deployment/myapp
                        "
                    '''
                }
            }
        }
    }
}