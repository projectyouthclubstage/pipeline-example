import java.text.SimpleDateFormat

pipeline {
  agent {
    kubernetes {
      yamlFile 'build.yaml'
    }
  }
  environment {
    def mybuildversion = getBuildVersion(env.BUILD_NUMBER)
    def gitBranch = ""
    def projektname = ""
    def registry = ""
    def healthpath = "/actuator/health"
    def port = "8080"
  }
  stages {

     stage('Prepare') {

        steps{
          script{
            def myRepo = checkout scm
            gitBranch = myRepo.GIT_BRANCH
            projektname = env.JOB_NAME.replace("/$gitBranch","").replace("YouthClubstage/","")
            registry = "registry.youthclubstage.de:5000/${projektname}"
         }
         echo "$projektname"
         echo "$mybuildversion"
         echo "$registry"
         echo "$gitBranch"
        }
     }
     stage('Build') {
      steps {
       container('maven') {
         sh "mvn -B clean install -DskipTests=true"
       }
      }
     }
     stage('Test') {
       steps {
         container('maven') {
           sh """
             mvn -B test
             """
         }
        }
     }

     stage('Create Docker images') {
       when { changelog '.*#DeployDev.*' }
       steps {
        container('docker') {
            script{
             dockerImage = docker.build registry + ":$mybuildversion"
             dockerImage.push()
            }
        }
       }
     }
     stage('Deploy Deployment to DEV') {
       when { changelog '.*#DeployDev.*' }
       steps {
        container('kubectl') {
            sh "cat template/deployment.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g;s/{PORT}/$port/g;s/{BRANCH}/${GIT_BRANCH_LOCAL}/g' >> target/deployment.yaml"
            sh "cat target/deployment.yaml"
            sh "kubectl -n dev apply -f target/deployment.yaml"
        }
       }
     }
     stage('Deploy Service-Green to DEV') {
       when { changelog '.*#DeployDev.*' }
       steps {
        container('kubectl') {
            sh "cat template/service-green.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g;s/{PORT}/$port/g' >> target/service-green.yaml"
            sh "cat target/service-green.yaml"
            sh "kubectl -n dev apply -f target/service-green.yaml"
        }
       }
     }
     stage('Health Check Green'){
       when { changelog '.*#DeployDev.*' }
       steps {
        retry (3) {
          sleep 30
          httpRequest url:"http://$projektname-green-srv.dev$healthpath", validResponseCodes: '200'
        }
      }
     }
     stage('Deploy Service to DEV') {
       when { changelog '.*#DeployDev.*' }
       steps {
        container('kubectl') {
          script{
            sh "cat template/service.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g;s/{PORT}/$port/g' >> target/service.yaml"
            sh "cat target/service.yaml"
            sh "kubectl -n dev apply -f target/service.yaml"
            try{
             sh "kubectl -n dev delete all -l service=$projektname"
            }catch(Exception ex){

            }
            sh "kubectl -n dev label all -l run=$projektname-$mybuildversion service=$projektname"
          }
        }
       }
     }
     stage('Health Check'){
       steps {
        retry (3) {
          sleep 30
          httpRequest url:"http://$projektname-srv.dev$healthpath", validResponseCodes: '200'
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