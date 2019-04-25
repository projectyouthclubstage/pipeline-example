pipeline{

agent {
    docker {
        image 'maven:3-alpine'
        label 'my-defined-label'
        args  '-v /tmp:/tmp'
    }
}

  // Pipeline Stages start here
  // Requeres at least one stage

stages{
    // Checkout source code
    // This is required as Pipeline code is originally checkedout to
    // Jenkins Master but this will also pull this same code to this slave
    stage('Git Checkout') {
      scm checkout
    }

    // Run Maven build, skipping tests
    stage('Build'){
        sh "mvn -B clean install -DskipTests=true"
    }

    // Run Maven unit tests
    stage('Unit Test'){
        sh "mvn -B test"
    }
   }
}