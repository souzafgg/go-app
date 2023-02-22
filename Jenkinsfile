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
              dir('./k8s') {
              sh 'sed -i "s/{{TAG}}/$tag/g" deployment.yaml'  
              sh 'kubectl apply -f deployment.yaml --namespace=dev'
              }
              sh 'chmod +x get-ip.sh'
              sh 'sed -i "s/{{SW}}/dev/g" get-ip.sh'
              sh './get-ip.sh'
            }
          } else {
            withKubeConfig([credentialsId: 'kube-creds']) {
              dir('./k8s') {
              sh 'sed -i "s/{{TAG}}/$tag/g" deployment.yaml'
              sh 'kubectl apply -f deployment.yaml --namespace=prod'
              }
              sh 'chmod +x get-ip.sh'
              sh 'sed -i "s/{{SW}}/prod/g" get-ip.sh'
              sh './get-ip.sh'
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
        script {
          withKubeConfig([credentialsId: 'kube-creds']) {
            dir('./k8s') {
            sh 'kubectl delete -f deployment.yaml --namespace=dev'
            }
          }
        }
      }
    }
  }
  post {
    always {
        sh 'echo "Testing if the hosts are ok"'
        withKubeConfig([credentialsId: 'kube-creds']) {
        ansiblePlaybook(credentialsId: 'jenkins', inventory: 'hosts', playbook: 'playbooks/playbook.yaml')
        }
      }
    }
  }

