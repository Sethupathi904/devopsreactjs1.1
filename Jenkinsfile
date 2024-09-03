pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gcr.io/groovy-legacy-434014-d0/react-app' // GCP Artifact Registry image name
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

        stage('Push Docker Image to GCP Artifact Registry') {
            steps {
                script {
                    echo "Pushing Docker Image to GCP Artifact Registry"
                    withCredentials([file(credentialsId: 'kubernetes', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        // Debugging: Show current auth status
                        sh "gcloud auth list"
                        
                        // Authenticate with GCP
                        sh "gcloud auth activate-service-account --key-file=${CREDENTIALS_ID}"
                        
                        // Debugging: Confirm the auth succeeded
                        sh "gcloud config list account"
                        
                        // Configure Docker to use GCP Artifact Registry
                        sh "gcloud auth configure-docker gcr.io --quiet"
                    }
                    
                    // Push the Docker image to GCP Artifact Registry
                    sh "docker push ${IMAGE_NAME}:${env.BUILD_ID}"
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                echo "Deployment started ..."
                sh 'ls -ltr'
                sh 'pwd'
                sh "sed -i 's|gcr.io/groovy-legacy-434014-d0/react-app:latest|${IMAGE_NAME}:${env.BUILD_ID}|g' deployment.yaml"
                sh "sed -i 's/tagversion/${env.BUILD_ID}/g' deployment.yaml"
                sh "sed -i 's/tagversion/${env.BUILD_ID}/g' serviceLB.yaml"
                echo "Start deployment of serviceLB.yaml"
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'serviceLB.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
                echo "Start deployment of deployment.yaml"
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'deployment.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
                echo "Deployment Finished ..."
            }
        }
    }

    post {
        always {
            cleanWs() // Cleans workspace after build
        }
    }
}
