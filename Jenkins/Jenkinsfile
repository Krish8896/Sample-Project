def registry = 'https://helloworlds.jfrog.io/'
pipeline {
    agent {
        node {
            label 'maven'
        }
    } 
environment {
        PATH = "/opt/apache-maven-3.9.4/bin:$PATH"
}
    stages {
        stage ('Build') {
            steps {
                echo 'Building...'
                sh 'mvn clean deploy -Dmaven.test.skip=true'  // Skip tests during build
                echo 'Build completed.'
            }
        }
        stage('test') {
            steps {
                echo 'Running tests...'
                sh 'mvn surefire-report:report'
                echo 'Tests completed.'
            }
        }
        stage('SonarQube analysis') {
        environment {
            scannerHome = tool 'org-sonarqube-scanner'
        }
            steps {
                withSonarQubeEnv('org-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name }
                sh "${scannerHome}/bin/sonar-scanner"
            }
            }
        }
      //  stage("Quality Gate"){
      //      steps {
      //      script {
      //          timeout(time: 15, unit: 'MINUTES') { // Just in case something goes wrong, pipeline will be killed after a timeout
      //          def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
      //          if (qg.status != 'OK') {
      //              error "Pipeline aborted due to quality gate failure: ${qg.status}"
    //}
  //}
     //   }
   // }
    //    } 
        stage("Jar Publish") {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"artifact-cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "mavenrepo-libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
                }       
            }   
        } 
    }
}
