pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        IMAGE_NAME = 'pipeline-app'
        ECR_REPO = '878311920432.dkr.ecr.ap-south-1.amazonaws.com/pipeline-app'
        CONTAINER_NAME = 'pipeline-container'
        EC2_HOST = 'ubuntu@54.167.104.165'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Pulling latest code from GitHub..."
                checkout scm
            }
        }

        // Build and test using the official Maven Docker image via docker run
        stage('Build and Test') {
            steps {
                echo "Building the Java project and running unit tests inside a Maven container..."
                sh '''
                echo "Running Maven build in a Docker container..."
                # Mount the Jenkins workspace into the Maven container and run Maven there.
                # The workspace will be at /usr/src/mymaven inside the container.
                docker run --rm -v "$WORKSPACE":/usr/src/mymaven -w /usr/src/mymaven maven:3.8.6-openjdk-11 mvn -B clean package -DskipTests

                echo "Running automated tests in a Docker container..."
                docker run --rm -v "$WORKSPACE":/usr/src/mymaven -w /usr/src/mymaven maven:3.8.6-openjdk-11 mvn test
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image for the Java application..."
                sh '''
                docker build -t $IMAGE_NAME .
                docker tag $IMAGE_NAME:latest $ECR_REPO:latest
                '''
            }
        }

        stage('Login and Push to AWS ECR') {
            steps {
                echo "Logging into AWS ECR and pushing Docker image..."
                sh '''
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                docker push $ECR_REPO:latest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo "Deploying Docker container to EC2 instance..."
                sshagent(['ec2-ssh']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $EC2_HOST "
                        echo 'Pulling latest Docker image from ECR...'
                        docker pull $ECR_REPO:latest &&
                        echo 'Stopping old container if running...'
                        docker stop $CONTAINER_NAME || true &&
                        docker rm $CONTAINER_NAME || true &&
                        echo 'Running new container...'
                        docker run -d -p 80:80 --name $CONTAINER_NAME $ECR_REPO:latest
                    "
                    '''
                }
            }
        }

        stage('Verify and Monitor Deployment') {
            steps {
                echo "Verifying container status and sending CloudWatch metric..."
                sh '''
                # Check Docker container running on EC2
                ssh -o StrictHostKeyChecking=no $EC2_HOST "docker ps"

                # Send a success metric to CloudWatch
                aws cloudwatch put-metric-data --metric-name DeploymentStatus \
                  --namespace CI-CD-Pipeline --value 1 --region $AWS_REGION
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully! Application deployed to EC2.'
        }
        failure {
            echo '❌ Pipeline failed. Please check Jenkins console output.'
        }
    }
}
