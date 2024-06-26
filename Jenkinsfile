/* import eazy-shared-library */
@Library('eazy-shared-library')_

pipeline {
     environment {
       ID_DOCKER = "${ID_DOCKER_PARAMS}" // à paramétrer 
       IMAGE_NAME = "alpinehelloworld"
       IMAGE_TAG = "latest"
       PORT_EXPOSED = "80" //à paraméter dans le job
       // heroku_api_key (paramétrer la clé heroku dans les credentials)
       // dockerhub (paramétrer le mot de passe du docker hub dans les credentials)   
       IP_VM_JENKINS = "http://ec2-3-86-32-113.compute-1.amazonaws.com"
       STAGING = "${ID_DOCKER}-staging"
       PRODUCTION = "${ID_DOCKER}-production"
     }
     agent none
     stages {
         stage('Build image') {
             agent any
             steps {
                script {
                  sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
                }
             }
        }
        stage('Run container based on builded image') {
            agent any
            steps {
               script {
                 sh '''
                    echo "Clean Environment"
                    docker rm -f $IMAGE_NAME || echo "container does not exist"
                    docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:5000 -e PORT=5000 ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5
                 '''
               }
            }
       }
       stage('Test image') {
           agent any
           steps {
              script {
                sh '''
                    # curl http://172.17.0.1:${PORT_EXPOSED} | grep -q "Hello world!"
                    curl ${IP_VM_JENKINS}:${PORT_EXPOSED} | grep  "Hello world!"
                '''
              }
           }
      }
      stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }

     stage ('Login and Push Image on docker hub') {
          agent any
        environment {
           DOCKERHUB_PASSWORD  = credentials('dockerhub')
        }            
          steps {
             script {
               sh '''
                   echo $DOCKERHUB_PASSWORD | docker login -u $ID_DOCKER --password-stdin
                   docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
               '''
             }
          }
      }    
     
     stage('Push image in staging and deploy it') {
       when {
              // expression { GIT_BRANCH == 'origin/master' }
            expression { GIT_BRANCH == 'just_to_force_failure' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
          script {
            sh '''
              npm i -g heroku@7.68.0
              heroku container:login
              heroku create $STAGING || echo "project already exist"
              heroku container:push -a $STAGING web
              heroku container:release -a $STAGING web
            '''
          }
        }
     }



     stage('Push image in production and deploy it') {
       when {
              expression { GIT_BRANCH == 'origin/production' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
          script {
            sh '''
              npm i -g heroku@7.68.0
              heroku container:login
              heroku create $PRODUCTION || echo "project already exist"
              heroku container:push -a $PRODUCTION web
              heroku container:release -a $PRODUCTION web
            '''
          }
        }
     }
  }
  post {
       always {
           script {
             slackNotifier currentBuild.result
               }
          }  
     }  
}
