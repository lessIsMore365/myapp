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
                sh '''
            mvn clean package -DskipTests
            echo "=== 检查 target 目录 ==="
            ls -l target
        '''
            }
        }

        stage('Deploy Remotely') {
            steps {
                sshagent(['vm-ssh-key']) {
                    sh '''
                # 上传 jar 包、Dockerfile 和 deployment.yaml
                scp -o StrictHostKeyChecking=no target/*.jar Dockerfile deployment.yaml ${REMOTE_USER}@${REMOTE_HOST}:/home/xz/

                # 在远程主机上执行镜像构建、推送和部署
                ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                    set -e  # 遇到错误立即退出

                    echo '==== 登录 Harbor ===='
                    docker login 192.168.3.41:8080 -u admin -p Harbor12345

                    echo '==== 构建并推送镜像 ===='
                    docker build -t ${REGISTRY}:${IMAGE_TAG} /home/xz
                    docker push ${REGISTRY}:${IMAGE_TAG}

                    echo '==== 更新或创建 K8s 部署 ===='
                    # 检查 Deployment 是否存在
                    if kubectl -n ${DEPLOY_NS} get deploy myapp > /dev/null 2>&1; then
                        echo 'Deployment 已存在，更新镜像...'
                        kubectl -n ${DEPLOY_NS} set image deployment/myapp myapp=${REGISTRY}:${IMAGE_TAG}
                    else
                        echo 'Deployment 不存在，创建部署...'
                        kubectl apply -f /home/xz/deployment.yaml -n ${DEPLOY_NS}
                    fi

                    kubectl -n ${DEPLOY_NS} rollout status deployment/myapp
                "
            '''
                }
            }
        }

    }
}