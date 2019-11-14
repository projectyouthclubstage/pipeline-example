import java.text.SimpleDateFormat
pipeline{
  agent any
  environment {
    def mybuildverison = getBuildVersion(env.BUILD_NUMBER)
    def projektname = "pipeline-example"
    def registry = "registry.youthclubstage.de/pipeline-example"
    def dns = "pe.youthclubstage.de"
    def dnsblue = "peb.youthclubstage.de"
    def port = "8080"
  }


stages{

       stage('docker build')
       {
           steps{
             checkout scm
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
