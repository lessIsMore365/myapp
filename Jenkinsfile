pipeline {
    agent any

    tools {
        maven 'maven3.9.11'
    }

    environment {
        REGISTRY = "lessIsMore365/myapp"
        IMAGE_TAG = "latest"
        DEPLOY_NS = "cicd"
        KUBECONFIG = "/home/xz/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/lessIsMore365/myapp.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build & Push Image with Kaniko') {
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
"""
                }
            }
            environment {
                DOCKER_CONFIG = '/kaniko/.docker/'
            }
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            mkdir -p /kaniko/.docker
                            cat <<EOF > /kaniko/.docker/config.json
                            {
                              "auths": {
                                "https://index.docker.io/v1/": {
                                  "username": "$DOCKER_USER",
                                  "password": "$DOCKER_PASS"
                                }
                              }
                            }
                            EOF

                            /kaniko/executor \
                              --context `pwd` \
                              --dockerfile `pwd`/Dockerfile \
                              --destination=$REGISTRY:$IMAGE_TAG \
                              --verbosity info
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sshagent(['k8s-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no xz@10.211.55.4 "
                            kubectl set image deployment/myapp myapp=$REGISTRY:$IMAGE_TAG -n $DEPLOY_NS
                            kubectl rollout status deployment/myapp -n $DEPLOY_NS
                        "
                    '''
                }
            }
        }
    }
}
