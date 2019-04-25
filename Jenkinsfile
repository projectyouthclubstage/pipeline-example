pipeline{

agent {
    docker {
        image 'arm32v7/maven'
    }
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
     steps {
        sh "mvn -B clean install -DskipTests=true"
        }
    }

    // Run Maven unit tests
    stage('Unit Test'){
     steps {
        sh "mvn -B test"
        }
    }

    stage('docker')
    {
     steps {
        docker.build("my-image:${env.BUILD_ID}")
        }
    }
   }
}