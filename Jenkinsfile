import java.text.SimpleDateFormat

def label = "worker-${UUID.randomUUID().toString()}"


 podTemplate(label: label, containers: [
   containerTemplate(name: 'jnlp', image: 'registry.youthclubstage.de:5000/jnlp-slave:6', args: '${computer.jnlpmac} ${computer.name}'),
   containerTemplate(name: 'maven', image: 'arm32v7/maven', command: 'cat', ttyEnabled: true),
   containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
   containerTemplate(name: 'kubectl', image: 'gitlabarm/kubectl', command: 'cat', ttyEnabled: true)
 ],
 volumes: [
   hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
 ]) {
   node(label) {
     def myRepo = checkout scm
     def gitCommit = myRepo.GIT_COMMIT
     def gitBranch = myRepo.GIT_BRANCH
     def shortGitCommit = "${gitCommit[0..10]}"
     def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
     def mybuildversion = getBuildVersion(env.BUILD_NUMBER)
     def projektname = "pipeline-example"
     def registry = "registry.youthclubstage.de:5000/pipeline-example"
     def healthpath = "/actuator/health"
     def port = "8080"

     stage('Build') {
       container('maven') {
         sh "mvn -B clean install -DskipTests=true"
       }
     }
     stage('Test') {
       try {
         container('maven') {
           sh """
             mvn -B test
             """
         }
       }
       catch (exc) {
         println "Failed to test - ${currentBuild.fullDisplayName}"
         throw(exc)
       }
     }

     stage('Create Docker images') {
       container('docker') {
           dockerImage = docker.build registry + ":$mybuildversion"
           dockerImage.push()
       }
     }
     stage('Deploy Deployment to DEV') {
       container('kubectl') {
           sh "cat template/deployment.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g' >> target/deployment.yaml"
           sh "cat target/deployment.yaml"
           sh "kubectl -n dev apply -f target/deployment.yaml"
       }
     }
     stage('Deploy Service-Green to DEV') {
       container('kubectl') {
           sh "cat template/service-green.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g' >> target/service-green.yaml"
           sh "cat target/service-green.yaml"
           sh "kubectl -n dev apply -f target/service-green.yaml"
       }
     }
     stage('Health Check'){
       retry (3) {
         sleep 30
         httpRequest url:"http://$projektname-green-srv$healthpath", validResponseCodes: '200'
       }
     }
     stage('Deploy Service to DEV') {
       container('kubectl') {
           sh "cat template/service.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g' >> target/service.yaml"
           sh "cat target/service.yaml"
           sh "kubectl -n dev apply -f target/service.yaml"
           try{
            sh "kubectl -n dev delete all -l service=$projektname"
           }catch(Exception ex){

           }
           sh "kubectl -n dev label all -l run=$projektname-$mybuildversion service=$projektname"
       }
     }
     /*
     stage('Run helm') {
       container('helm') {
         sh "helm list"
       }
     }*/
   }
 }

 def getBuildVersion(String buildnr){
     def dateFormat = new SimpleDateFormat("yyyyMMddHHmm")
     def date = new Date()
     return dateFormat.format(date)+buildnr
 }
