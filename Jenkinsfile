pipeline {
  agent any
  environment {
    brc = "${env.BRANCH_NAME}"
    tag = "${env.BUILD_ID}"
  }
  stages {
    stage ("Building image") {
      steps {
          script {
            sh 'echo "Building image with $brc"'
            sh 'sed -i "s/x/$brc/g" ./main.go'
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
          if (env.BRANCH_NAME != 'main') {
            withKubeConfig([credentialsId: 'kube-creds']) {
              sh 'sed -i "s/{{TAG}}/$tag/g" ./k8s/deployment.yaml'
              dir('./k8s') {
              sh 'kubectl apply -f deployment.yaml --namespace=dev'
              }
            }
          } else {
            withKubeConfig([credentialsId: 'kube-creds']) {
              sh 'sed -i "s/{{TAG}}/$tag/g" ./k8s/deployment.yaml'
              dir('./k8s') {
              sh 'kubectl apply -f deployment.yaml --namespace=prod'
              }
            }
          }
        }  
      }
    }
    stage ("validate the deployment rm") {
      when {
        beforeInput true
        expression { env.BRANCH_NAME != 'main' }
      }
      input {
        message 'Do you want to remove your last k apply in dev namespace?'
        ok 'ok'
      }
      steps {
        sh 'sed -i "s/{{TAG}}/$tag/g" ./k8s/deployment.yaml'
        dir('./k8s') {
        sh 'kubectl delete -f deployment.yaml --namespace=dev'
        }
      }
    }
  }
  post {
    always {
        sh 'echo "Testing if the hosts are ok"'
        ansiblePlaybook(credentialsId: 'jenkins', inventory: 'hosts', playbook: 'playbooks/playbook.yaml')
      }
    }
  }

