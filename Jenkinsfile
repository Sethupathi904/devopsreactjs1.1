pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub' // Jenkins credentials ID for Docker Hub
        IMAGE_NAME = 'sethu904/react-app' // Docker image name
        PROJECT_ID = 'groovy-legacy-434014-d0'
        CLUSTER_NAME = 'k8s-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = 'kubernetes'
        PATH = "/usr/local/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm // Checks out code from the repository
            }
        }

        stage('Verify Docker') {
            steps {
                script {
                    sh 'docker --version'
                    sh 'docker info'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    myimage = docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker Image"
                    withCredentials([string(credentialsId: DOCKER_CREDENTIALS_ID, variable: 'DOCKER_PASSWORD')]) {
                        sh "echo ${DOCKER_PASSWORD} | docker login -u sethu904 --password-stdin"
                    }
                    myimage.push("${env.BUILD_ID}")
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                script {
                    echo "Deployment started ..."
                    sh 'ls -ltr'
                    sh 'pwd'
                    sh "sed -i 's/tagversion/${env.BUILD_ID}/g' serviceLB.yaml"
                    sh "sed -i 's/tagversion/${env.BUILD_ID}/g' deployment.yaml"
                    echo "Deploying serviceLB.yaml"
                    step([$class: 'KubernetesEngineBuilder', projectId: PROJECT_ID, clusterName: CLUSTER_NAME, location: LOCATION, manifestPattern: 'serviceLB.yaml', credentialsId: CREDENTIALS_ID, verifyDeployments: true])
                    echo "Deploying deployment.yaml"
                    step([$class: 'KubernetesEngineBuilder', projectId: PROJECT_ID, clusterName: CLUSTER_NAME, location: LOCATION, manifestPattern: 'deployment.yaml', credentialsId: CREDENTIALS_ID, verifyDeployments: true])
                    echo "Deployment Finished ..."
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Cleans workspace after build
        }
    }
}
