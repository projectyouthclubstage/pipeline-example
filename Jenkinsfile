pipeline{

agent none
  environment {
    registry = "192.168.233.1:5000/pipeline-example"

  }

  // Pipeline Stages start here
  // Requeres at least one stage

stages{
    // Checkout source code
    // This is required as Pipeline code is originally checkedout to
    // Jenkins Master but this will also pull this same code to this slave
    //stage('Git Checkout') {
    // steps {
    //   checkout
    //  }
    //}

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




       stage('docker')
       {
          agent {
               label 'master'
           }
           steps{
            script{
               //sh "docker build ./ -t "+ registry + ":$BUILD_NUMBER"
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
                      sh "cat docker-compose-template.yml | sed -e 's/{version}/"+":$BUILD_NUMBER"+"/g' >> docker-compose.yml"
                      //dockerImage = docker.build registry + ":$BUILD_NUMBER"
                      //dockerImage.push()
                     }
                   }
       }
   }
}
