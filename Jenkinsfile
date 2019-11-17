import java.text.SimpleDateFormat

def label = "worker-${UUID.randomUUID().toString()}"
def mybuildverison = getBuildVersion(env.BUILD_NUMBER)
def projektname = "pipeline-example"
def registry = "registry.youthclubstage.de:5000/pipeline-example"
def dns = "pe.youthclubstage.de"
def dnsblue = "peb.youthclubstage.de"
def port = "8080"

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
           dockerImage = docker.build registry + ":$mybuildverison"
           dockerImage.push()
       }
     }
     stage('Run kubectl') {
       container('kubectl') {
           sh """
             kubectl apply "apiVersion: v1
                              kind: Service
                              metadata:
                                name: $(projektname)-srv-green
                                labels:
                                  run: $(projektname)-$(mybuildverison)
                              spec:
                                type: NodePort
                                ports:
                                - port: 80
                                  targetPort: 8080
                                  protocol: TCP
                                  name: http
                                selector:
                                  run: $(projektname)-$(mybuildverison)
                              ---
                              apiVersion: apps/v1
                              kind: Deployment
                              metadata:
                                name: $(projektname)-$(mybuildverison)
                              spec:
                                selector:
                                  matchLabels:
                                    run: $(projektname)-$(mybuildverison)
                                replicas: 3
                                template:
                                  metadata:
                                    labels:
                                      run: $(projektname)-$(mybuildverison)
                                  spec:
                                    containers:
                                    - name: $(projektname)-$(mybuildverison)
                                      image: registry.youthclubstage.de:5000/p$(projektname):$(mybuildverison)
                                      ports:
                                      - containerPort: 8080
                              "
             """
       }
     }/*
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
