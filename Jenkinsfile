pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
        git 'Default-Git'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        PATH = "/usr/bin:$PATH"
        //NEXUS_URL = 'http://100.119.108.38:8081/repository/docker-releases/'
        
    }

    stages {

        stage('Cleanup Workspace') {
            steps {
                deleteDir()
            }
        }
            
        stage('Git Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-bitra-devops', url: 'https://github.com/bitra-devops/devops-lab-landingpage.git']])
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-scanner') { // Ensure SonarQube is configured in Jenkins
                    sh "${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=devops-landingpage \
                        -Dsonar.projectName=devops-landingpage \
                        -Dsonar.sources=. \
                        -Dsonar.java.binaries=."
                }
            }
        }

        stage('Dockerhub Login') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/') {
                        echo "Docker login successful using Jenkins credentials."
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def incrementalTag = "santoshbitradocker/devops-landing-page:${env.BUILD_NUMBER}"
                    def latestTag = "santoshbitradocker/devops-landing-page:latest"

                    sh "docker build -t ${incrementalTag} -t ${latestTag} ."
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                script {
                    def incrementalTag = "santoshbitradocker/devops-landing-page:${env.BUILD_NUMBER}"
                    def latestTag = "santoshbitradocker/devops-landing-page:latest"

                    withDockerRegistry(credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/') {
                        sh "docker push ${incrementalTag}"
                        sh "docker push ${latestTag}"
                    }
                }
            }
        }


        stage('Push Docker Image to Nexus') {
            steps {
                script {
                    def dockerRegistry = "100.119.108.38:8081"
                    def imageName = "devops-landingpage"
                    def incrementalTag = "santoshbitradocker/devops-landing-page:${env.BUILD_NUMBER}"
                    def latestTag = "santoshbitradocker/devops-landing-page:latest"
                    
                        // Docker login to Nexus
                        sh "docker login --username admin --password PostDomulur@123 --insecure-registry http://${dockerRegistry}"  
                        // Push Docker images to Nexus
                        sh "docker push ${incrementalTag}"
                        sh "docker push ${latestTag}"
                    }
                }
            }
        }



        stage('Stop Existing Container') {
            steps {
                script {
                    // Stop the container if it exists
                    sh """
                    CONTAINER_ID=\$(docker ps -q -f name=landing-page)
                    if [ -n "\$CONTAINER_ID" ]; then
                        echo "Stopping existing container..."
                        docker stop \$CONTAINER_ID
                        docker rm \$CONTAINER_ID
                    else
                        echo "No existing container to stop."
                    fi
                    """
                }
            }
        }


        stage('Docker Compose') {
            steps {
                script {
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    def url = "http://100.119.108.38:8082"
            
                    try {
                        // Using the httpRequest step
                        def response = httpRequest(
                        url: url,
                        httpMode: 'GET',
                        acceptType: 'APPLICATION_JSON',
                        timeout: 30000
                        )
                
                        // Check the response code and proceed accordingly
                echo "Successfully connected to ${url} with response: ${response}"
            } catch (Exception e) {
                error("Failed to connect to ${url}: ${e.message}")
                }
                }
            }            
        }
    }
}
