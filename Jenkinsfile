pipeline {
  agent any
  environment {
    branch = "${env.BRANCH_NAME}"
    tag = "${env.BUILD_ID}"
  }
  stages {
    stage ("Building image") {
      steps {
          sh 'Building image with $branch'
          script {
            sh 'sed -i "s/tag/$branch/g" ./main.go'
            dockerapp = docker.build("szadhub/go-app:$tag", "-f Dockerfile ./")
          }
      }
    }
    stage ("Uploading image to dockerhub") {
      steps {
        script {
          docker.withRegistry('https://registry.hub.docker.com', 'docker-creds') {
            dockerapp.push(tag)
          }
        }
      }
    }
    stage ("Updating Kubernetes deployment with the new image") {
      steps {
        script {
          if ($branch != 'main') {
            withKubeConfig([credentialsId: 'kube-creds']) {
              sh 'sed -i "s/{{tag}}/$tag/g" ./k8s/deployment.yaml'
              sh 'kubectl apply -f ./k8s/deployment.yaml --namespace=dev'
          }
        } else {
            withKubeConfig([credentialsId: 'kube-creds']) {
              sh 'sed -i "s/{{tag}}/$tag/g" ./k8s/deployment.yaml'
              sh 'kubectl apply -f ./k8s/deployment.yaml --namespace=prod'
            }
          }
        } 
      }
    }
    stage ("If prod = validate the deployment removal") {
      when {
        branch != 'main'
      }
      input {
        message 'Remove?'
        ok 'ok'
      }
      steps {
        sh 'kubectl delete -f ./k8s/deployment.yaml --namespace=prod'
      }
    }
  }
  post {
    always {
      steps {
          sh 'Testing if the hosts are ok'
          ansiblePlaybook credentialsId: 'jenkins', inventory: 'hosts', playbook: 'playbooks/playbook.yaml'
      }
    }
  }
}