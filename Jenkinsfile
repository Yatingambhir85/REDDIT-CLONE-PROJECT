pipeline{
  agent any
  tools{
    jdk 'jdk17'
    nodejs 'node18'
  }
  environment{
    SONAR_SCANNER = tool 'sonar-scanner'
    APP_NAME = "reddit-clone"  
    DOCKER_USER = "yatingambhir"
    DOCKER_PASS = 'docker-hub'
    IMAGE_TAG = "${BUILD_NUMBER}"
    IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}" + ":" + "${IMAGE_TAG}"
    AWS_ACCESS_KEY = credentials('AWS_ACCESS_KEY')
    AWSS_SECRET_KEY = credentials('AWSS_SECRET_KEY')
    AWS_DEFAULT_REGION = 'us-east-1'
  }
  stages{
    stage("clean workspace"){
      steps{
        cleanWs()
      }
    }
    stage("git checkout"){
      steps{
        git branch: 'main', url: 'https://github.com/Yatingambhir85/a-reddit-clone-yatin'
      }
    }    
    stage("sonarqube analysis"){
      steps{
        withSonarQubeEnv('sonar-server'){
          sh '$SONAR_SCANNER/bin/sonar-scanner -Dsonar.projectName=reddit-clone-ci -Dsonar.projectKey=reddit-clone-ci'
        }
      }
    }
    stage("quality gate"){
      steps{
        script{
          waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
        }
      }
    }
    stage("install dependencies"){
      steps{
        sh 'npm install'
      }
    }
    stage("docker build & push"){
      steps{
        script{
          withDockerRegistry(credentialsId: 'docker-hub', toolName: 'docker'){
            sh 'docker build -t "${APP_NAME}" .'       
            sh 'docker tag "${APP_NAME}" "${IMAGE_NAME}"'    
            sh 'docker push "${IMAGE_NAME}"'
          }
        }
      }
    }
    stage("cleaunp artifacts"){
      steps{
        sh 'docker rmi "${IMAGE_NAME}"'
      }
    }
    stage("Update the deployment file"){
      steps{
        sh """
                    cat deployment.yaml
                    sed -i 's/${APP_NAME}.*/${APP_NAME}:${IMAGE_TAG}/g' deployment.yaml
                    cat deployment.yaml
            """
          }
    }
    stage("Deployment to Kubernetes"){
      steps{
        script{
                sh ('aws eks update-kubeconfig --name EKS-REDDIT-PROJECT --region us-east-1')
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'
        }
      }
    }
  }
  post{
    always{
      emailext attachLog: true,
        subject: "'${currentBuild.result}'",
        body: "Project: ${env.JOB_NAME}<br/>" +
              "Build Number: ${env.BUILD_NUMBER}<br/>" + 
              "Build URL: ${env.BUILD_URL}<br/>",
        to: 'yatingambhir85@gmail.com'
    }
  }
}
