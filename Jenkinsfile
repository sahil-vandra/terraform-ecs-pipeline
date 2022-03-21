pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID="997817439961"
        AWS_DEFAULT_REGION="ap-south-1" 
        IMAGE_REPO_NAME="sahil-demo"
        IMAGE_TAG="prod-img_${GIT_COMMIT}"
        CLUSTER_NAME="Production-Cluster"
        SERVICE_NAME="Prod-Service"
        TASK_DEFINITION_NAME="Production"
        DESIRED_COUNT="1"
    }
    
    stages {
        
        stage('Trigger pipeline and clone code') {
            steps {
                git branch: 'prod', url: 'https://github.com/sahil-vandra/Production.git'
                               
                sh "chmod +x -R ${env.WORKSPACE}"
                sh "./script-prod.sh"
            }
        }
      
    }
}
