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
     def mybuildversion = getBuildVersion(env.BUILD_NUMBER)
     def projektname = env.JOB_NAME.replace("/${GIT_BRANCH_LOCAL}","").replace("projectyouthclubstage/","")
     def registry = "registry.youthclubstage.de:5000/${projektname}"
     def healthpath = "/actuator/health"
     def port = "8080"
     stage('Prepare') {
         echo "$projektname"
         echo "$mybuildversion"
         echo "$registry"
         echo "${GIT_BRANCH_LOCAL}"
     }
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
       when { changelog '.*#DeployDev.*' }
       container('docker') {
           dockerImage = docker.build registry + ":$mybuildversion"
           dockerImage.push()
       }
     }
     stage('Deploy Deployment to DEV') {
       when { changelog '.*#DeployDev.*' }
       container('kubectl') {
           sh "cat template/deployment.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g;s/{PORT}/$port/g;s/{BRANCH}/${GIT_BRANCH_LOCAL}/g' >> target/deployment.yaml"
           sh "cat target/deployment.yaml"
           sh "kubectl -n dev apply -f target/deployment.yaml"
       }
     }
     stage('Deploy Service-Green to DEV') {
       when { changelog '.*#DeployDev.*' }
       container('kubectl') {
           sh "cat template/service-green.yaml | sed -e 's/{NAME}/$projektname/g;s/{VERSION}/$mybuildversion/g;s/{PORT}/$port/g' >> target/service-green.yaml"
           sh "cat target/service-green.yaml"
           sh "kubectl -n dev apply -f target/service-green.yaml"
       }
     }
     stage('Health Check Green'){
       when { changelog '.*#DeployDev.*' }
       retry (3) {
         sleep 30
         httpRequest url:"http://$projektname-green-srv.dev$healthpath", validResponseCodes: '200'
       }
     }
     stage('Deploy Service to DEV') {
       when { changelog '.*#DeployDev.*' }
       container('kubectl') {
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
     stage('Health Check'){
       retry (3) {
         sleep 30
         httpRequest url:"http://$projektname-srv.dev$healthpath", validResponseCodes: '200'
       }
     }
   }
 }

 def getBuildVersion(String buildnr){
     def dateFormat = new SimpleDateFormat("yyyyMMddHHmm")
     def date = new Date()
     return dateFormat.format(date)+buildnr
 }
