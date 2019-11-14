import java.text.SimpleDateFormat

/**
 * This pipeline will execute a simple Maven build
 */

podTemplate(containers: [
  containerTemplate(name: 'maven', image: 'maven:3.3.9-jdk-8-alpine', ttyEnabled: true, command: 'cat')
  ]) {

  node(POD_LABEL) {
    stage('Build a Maven project') {
      container('maven') {
          sh 'mvn -B clean package'
      }
    }
  }


agent none
  environment {

    def mybuildverison = getBuildVersion(env.BUILD_NUMBER)
    def projektname = "pipeline-example"
    def registry = "192.168.233.1:5000/pipeline-example"
    def dns = "pe.youthclubstage.de"
    def dnsblue = "peb.youthclubstage.de"
    def port = "8080"

  }


stages{

       stage('docker build')
       {
           steps{
            script{
                if (env.BRANCH_NAME == 'master') {
               dockerImage = docker.build registry + ":$mybuildverison"
               dockerImage.push()
               }
              }
           }
       }

}
}

def getBuildVersion(String buildnr){
    def dateFormat = new SimpleDateFormat("yyyyMMddHHmm")
    def date = new Date()
    return dateFormat.format(date)+buildnr
}
