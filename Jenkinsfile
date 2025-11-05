pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    tty: true
    command:
    - cat
    resources:
      requests:
        cpu: "50m"
        memory: "128Mi"
      limits:
        cpu: "200m"
        memory: "256Mi"
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker/
  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-secret
"""
        }
    }

    environment {
        REGISTRY = "lessIsMore365/myapp"
        IMAGE_TAG = "latest"
        DEPLOY_NS = "cicd"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/lessIsMore365/myapp.git'
            }
        }

        stage('Build Docker Image with Kaniko') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context `pwd` \
                          --dockerfile `pwd`/Dockerfile \
                          --destination=$REGISTRY:$IMAGE_TAG \
                          --skip-tls-verify
                    '''
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
