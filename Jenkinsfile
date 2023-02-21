pipeline {
  agent any
  environment {
    branch = "${env.BRANCH_NAME}"
    tag = "${env.BUILD_ID}"
  }
  stages {
    stage ("Building image") {
      steps {
          script {
            sh 'echo "Building image with $branch"'
            sh 'sed -i "s/x/$branch/g" ./main.go'
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
              sh 'sed -i "s/{{TAG}}/$tag/g" ./k8s/deployment.yaml'
              sh 'kubectl apply -f ./k8s/deployment.yaml --namespace=dev'
          }
        } else {
            withKubeConfig([credentialsId: 'kube-creds']) {
              sh 'sed -i "s/{{TAG}}/$tag/g" ./k8s/deployment.yaml'
              sh 'kubectl apply -f ./k8s/deployment.yaml --namespace=prod'
            }
          }
        } 
      }
    }
    stage ("If prod = validate the deployment removal") {
      when {
        expression { branch != 'main' }
      }
      input {
        message 'Remove?'
        ok 'ok'
      }
      steps {
        sh 'kubectl delete -f ./k8s/deployment.yaml --namespace=dev'
      }
    }
  }
  post {
    always {
      steps {
          sh 'echo "Testing if the hosts are ok"'
          ansiblePlaybook credentialsId: 'jenkins', inventory: 'hosts', playbook: 'playbooks/playbook.yaml'
        }
      }
    }
  }
