pipeline {
  agent any
  triggers {
    cron('H 2 * * *')
  }

  stages {

    stage('Scan used images with clair') {
      steps {
        node(label: 'clair') {
         script {
           try {
             sh '''/scan_catalog_entry.sh templates/www-eea eeacms/www-devel'''
             sh '''/scan_catalog_entry.sh  templates/www-plone eeacms/www'''
           } catch (err) {
              echo "Unstable: ${err}"
           }
         }
       }
     }
   }

    stage('Build & Tests - KGS') {
      steps {
        build job: '../eea.docker.kgs/master', parameters: [[$class: 'StringParameterValue', name: 'TARGET_BRANCH', value: 'master']]
      }
    }

    stage('Build & Tests - WWW') {
      steps {
        build job: '../eea.docker.plone-eea-www/master', parameters: [[$class: 'StringParameterValue', name: 'TARGET_BRANCH', value: 'master']]
      }
    }

    stage('Release - KGS') {
      steps {
        node(label: 'docker') {
          withCredentials([string(credentialsId: 'eea-jenkins-token', variable: 'GITHUB_TOKEN'), string(credentialsId: 'kgs-devel-new-trigger', variable: 'TRIGGER_URL'),usernamePassword(credentialsId: 'jekinsdockerhub', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
           sh '''docker pull eeacms/gitflow; docker run -i --rm --name="$BUILD_TAG-nightly-kgs" -e GIT_BRANCH="master" -e GIT_NAME="eea.docker.kgs" -e GIT_TOKEN="$GITHUB_TOKEN" -e TRIGGER_URL="$TRIGGER_URL" -e DOCKERHUB_USER="$DOCKERHUB_USER" -e DOCKERHUB_PASS="$DOCKERHUB_PASS" eeacms/gitflow'''
         }
       }
     }
   }

    stage('Release - WWW') {
      steps {
        node(label: 'docker') {
          withCredentials([string(credentialsId: 'eea-jenkins-token', variable: 'GITHUB_TOKEN'), string(credentialsId: 'www-devel-new-trigger', variable: 'TRIGGER_URL'), string(credentialsId: 'www-new-trigger', variable: 'TRIGGER_MAIN_URL'),usernamePassword(credentialsId: 'jekinsdockerhub', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
           sh '''docker pull eeacms/gitflow; docker run -i --rm --name="$BUILD_TAG-nightly-www" -e GIT_BRANCH="master" -e GIT_NAME="eea.docker.plone-eea-www" -e GIT_TOKEN="$GITHUB_TOKEN" -e TRIGGER_URL="$TRIGGER_URL"  -e TRIGGER_MAIN_URL="$TRIGGER_MAIN_URL" -e DOCKERHUB_USER="$DOCKERHUB_USER" -e DOCKERHUB_PASS="$DOCKERHUB_PASS" eeacms/gitflow'''
         }
       }
     }
   }

  }

  post {
    always {
      script {
        def url = "${env.BUILD_URL}/display/redirect"
        def status = currentBuild.currentResult
        def subject = "${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
        def summary = "${subject} (${url})"
        def details = """<h1>${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - ${status}</h1>
                         <p>Check console output at <a href="${url}">${env.JOB_BASE_NAME} - #${env.BUILD_NUMBER}</a></p>
                      """

        def color = '#FFFF00'
        if (status == 'SUCCESS') {
          color = '#00FF00'
        } else if (status == 'FAILURE') {
          color = '#FF0000'
        }
        slackSend (color: color, message: summary)
        emailext (subject: '$DEFAULT_SUBJECT', to: '$DEFAULT_RECIPIENTS', body: details)
      }
    }
  }
}
