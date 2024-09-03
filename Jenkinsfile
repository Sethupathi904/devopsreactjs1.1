pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'groovy-legacy-434014-d0'
        IMAGE_NAME = "gcr.io/${env.PROJECT_ID}/react-app"
        TAG = "${env.BUILD_ID}"
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image"
                    sh "docker build -t ${IMAGE_NAME}:latest ."
                    
                    echo "Tagging Docker Image"
                    sh "docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:${TAG}"
                    
                    echo "Listing Docker Images"
                    sh "docker images"
                }
            }
        }
        
		stage('Push Docker Image to GCP Artifact Registry') {
			steps {
				script {
					echo "Pushing Docker Image to GCP Artifact Registry"
					
					withCredentials([file(credentialsId: 'kubernetes', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
						// Authenticate with GCP
						sh "gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}"
						
						// Configure Docker to use GCP Artifact Registry
						sh "gcloud auth configure-docker gcr.io --quiet"
						
						// Push the Docker image
						sh "docker push gcr.io/groovy-legacy-434014-d0/react-app:${TAG}"
					}
				}
			}
		}

        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying to Kubernetes"
                    
                    // Set kubectl context
                    sh "gcloud container clusters get-credentials k8s-cluster --zone us-central1-c --project ${PROJECT_ID}"
                    
                    // Deploy to Kubernetes
                    sh "kubectl apply -f deployment.yaml"
                    sh "kubectl apply -f serviceLB.yaml"
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed'
        }
        success {
            echo 'Pipeline succeeded'
            // Email notification or other actions
        }
        failure {
            echo 'Pipeline failed'
            // Email notification or other actions
        }
    }
}
