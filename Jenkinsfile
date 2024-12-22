pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-bitra-devops', url: 'https://github.com/bitra-devops/devops-lab-landingpage.git']])
            }
        }

        stage('Docker Compose') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn test -DskipTests=true'
            }
        }                
                
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=Ekart -Dsonar.projectName=Ekart \
                    -Dsonar.java.binaries=. '''

                }
            }
        }            
    }
}
