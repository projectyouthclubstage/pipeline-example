pipeline{

agent none
  environment {
    def repo = "192.168.233.1:5000"
    def projektname = "pipeline-example"
    def registry = "192.168.233.1:5000/pipeline-example"
    def dns = "pe-blue.youthclubstage.de"
    def dnsblue = "pe-blue.youthclubstage.de"
    def port = "8080"

  }

  // Pipeline Stages start here
  // Requeres at least one stage

stages{

    // Run Maven build, skipping tests
    stage('Build'){
    agent {
        docker {
            image 'arm32v7/maven'
        }
    }
     steps {
        sh "mvn -B clean install -DskipTests=true"
        }
    }

    // Run Maven unit tests
    stage('Unit Test'){
    agent {
       docker {
           image 'arm32v7/maven'
          }
    }
     steps {
        sh "mvn -B test"
        }
    }

       stage('docker build')
       {
          agent {
               label 'master'
           }
           steps{
            script{
               dockerImage = docker.build registry + ":$BUILD_NUMBER"
               dockerImage.push()
              }
           }
       }

       stage('Docker deploy'){
                 agent {
                      label 'master'
                  }
                  steps{



                   script{
                      sh "cat docker-compose-template.yml | sed -e 's/{version}/"+"$BUILD_NUMBER"+"/g' >> target/docker-compose.yml"
                      def version = sh (
                          script: 'docker stack ls |grep '+projektname+'| cut -d \" \" -f1',
                          returnStdout: true
                      ).trim()
                      //sh "docker stack rm "+version
                      sh "docker stack deploy --compose-file target/docker-compose.yml "+projektname+"-"+"$BUILD_NUMBER"
                      sh "curl -d \'{\"source\": \""+dnsblue+"\",\"target\": \"http://"+projektname+"-$BUILD_NUMBER"+":8080\"}\' -H \"Content-Type: application/json\" -X POST http://192.168.233.1:9099/v1/dns"
                      sh 'docker kill --signal=HUP "$(docker ps |grep nginx |cut -d " " -f1)"'

                      //Green
                      sh "curl -d \'{\"source\": \""+dns+"\",\"target\": \"http://"+projektname+"-$BUILD_NUMBER"+":8080\"}\' -H \"Content-Type: application/json\" -X POST http://192.168.233.1:9099/v1/dns"
                      sh 'docker kill --signal=HUP "$(docker ps |grep nginx |cut -d " " -f1)"'
                      if(version != "")
                      {
                        sh "docker stack rm "+version
                      }

                     }
                   }
       }
   }
}
