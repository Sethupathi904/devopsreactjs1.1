pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'Password@9' // Jenkins credentials ID for Docker Hub
        IMAGE_NAME = 'sethu904/react-app' // Docker image name
        PROJECT_ID = 'groovy-legacy-434014-d0'
        CLUSTER_NAME = 'k8s-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = 'kubernetes'
        PATH = "/usr/local/bin:${env.PATH}"
    }

    stages {
		stages {
				stage('Checkout') {
					steps {
						script {
							checkout([$class: 'GitSCM',
								userRemoteConfigs: [[url: 'https://github.com/Sethupathi904/devopsreactjs1.1.git', credentialsId: 'your-git-credentials-id']],
								branches: [[name: '*/main']]
							])
						}
					}
				}
		}
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        docker.image("${IMAGE_NAME}:latest").push()
                    }
                }
            }
        }

        stage('Deploy to GKE') {
            steps {
                script {
                    // Authenticate with GKE
                    withCredentials([file(credentialsId: CREDENTIALS_ID, variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                        sh 'gcloud config set project ${PROJECT_ID}'
                        sh 'gcloud config set compute/zone ${LOCATION}'
                        sh 'gcloud container clusters get-credentials ${CLUSTER_NAME}'
                    }

                    // Apply Kubernetes manifests
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }
    }
}
