import java.text.SimpleDateFormat

pipeline{

agent none
  environment {

    def mybuildverison = getDate(env.BUILD_NUMBER)
    def projektname = "pipeline-example"
    def registry = "192.168.233.1:5000/pipeline-example"
    def dns = "pe.youthclubstage.de"
    def dnsblue = "peb.youthclubstage.de"
    def port = "8080"

  }


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
                if (env.BRANCH_NAME == 'master') {
               dockerImage = docker.build registry + ":$mybuildverison"
               dockerImage.push()
               }
              }
           }
       }

       stage('Docker deploy'){
                 agent {
                      label 'master'
                  }
                  steps{



                   script{
                      if (env.BRANCH_NAME == 'master') {
                        dockerDeploy(mybuildverison,projektname,dns,dnsblue,port)
                      }

                     }
                   }
       }
   }
     post {
       failure {
         script{
           sh "docker stack rm $projektname-$mybuildverison"
         }
       }
     }
}

def getDate(String buildnr){
    def dateFormat = new SimpleDateFormat("yyyyMMddHHmm")
    def date = new Date()
    return dateFormat.format(date)+buildnr
}

def dockerDeploy(String mybuildverison, String projektname, String dns, String dnsblue, String port){
                      sh "cat docker-compose-template.yml | sed -e 's/{version}/"+"$mybuildverison"+"/g' >> target/docker-compose.yml"
                      def version = sh (
                          script: 'docker stack ls |grep '+projektname+'| cut -d \" \" -f1',
                          returnStdout: true
                      ).trim()
                      //sh "docker stack rm "+version
                      sh "docker stack deploy --compose-file target/docker-compose.yml "+projektname+"-"+"$mybuildverison"


                      sleep 240 // second

                      sh "curl -d \'{\"source\": \""+dnsblue+"\",\"target\": \""+projektname+"-$mybuildverison"+":8080\"}\' -H \"Content-Type: application/json\" -X POST http://192.168.233.1:9099/v1/dns"
                      sh 'docker kill --signal=HUP "$(docker ps |grep nginx |cut -d " " -f1)"'


                      sleep 10 // second

                      //Health blue

                      retry (3) {
                          sleep 5
                          httpRequest url:"https://$dnsblue/actuator/health", validResponseCodes: '200', validResponseContent: '"status":"UP"'
                      }


                      //Green
                      sh "curl -d \'{\"source\": \""+dns+"\",\"target\": \""+projektname+"-$mybuildverison"+":8080\"}\' -H \"Content-Type: application/json\" -X POST http://192.168.233.1:9099/v1/dns"
                      sh 'docker kill --signal=HUP "$(docker ps |grep nginx |cut -d " " -f1)"'


                      sleep 10 // second

                      //Health green2

                      retry (3) {
                          sleep 5
                          httpRequest url:"https://$dns/actuator/health", validResponseCodes: '200', validResponseContent: '"status":"UP"'
                      }

                      if(version != "")
                      {
                        sh "docker stack rm "+version
                      }
}
