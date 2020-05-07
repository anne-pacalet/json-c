pipeline {
  agent any
  parameters {
    choice(name: 'freq', choices: 'high', description: 'frequency')
    string(name: 'memory', defaultValue: '700M', description: '')
    string(name: 'timeout',  defaultValue: '6m', description: '')
  }
  triggers {
    parameterizedCron('''
      H H(2-6) *    * * % freq=high; memory=700M; timeout=6m
        ''')
  }
  stages {
    stage('Run analysis') {
      steps {
        withCredentials([usernamePassword(\
              credentialsId: 'DOCKER_REGISTRY_IDS', \
              passwordVariable: 'DOCKER_REGISTRY_PASSWORD', \
              usernameVariable: 'DOCKER_REGISTRY_USERNAME')\
        ]) {
          sh """docker login \
                  --username=$DOCKER_REGISTRY_USERNAME \
                  --password=$DOCKER_REGISTRY_PASSWORD \
                  https://$DOCKER_REGISTRY \
             """
          sh """docker pull $DOCKER_REGISTRY/tis-analyzer:16.04"""
          sh """docker run \
                  --rm \
                  --security-opt seccomp=unconfined \
                  --memory=${params.memory} \
                  --volume $WORKSPACE:/scripts \
                  --workdir /scripts \
                  $DOCKER_REGISTRY/tis-analyzer:16.04 \
                  bash -c "source ~/.bashrc && \
                      echo -n GIT_COMMIT:tis-analyzer: && \
                      ( cat $DOCKER_JENKINS_HOME/installs/master/snapshot | \
                          grep -Po '[a-z0-9]* (?=utils/\$)' ) && \
                      tis_choose master && \
                      freq=${params.freq} timeout -k10s ${params.timeout} \
                      /scripts/tis/jenkins.sh -f -v -v" \
             """
        }
      }
    }
    stage('Test') {
      steps {
        junit testResults: 'tis/xunit.xml'
      }
    }
  }
  post {
        success {
            sendChatNotif('good')
        }

        unstable {
            sendChatNotif('warning')
        }

        failure {
            sendChatNotif('danger')
        }

        aborted {
            sendChatNotif('#808080')
        }

        unsuccessful {
            sendMailNotif('high', 'anne.pacalet')
        }
    }
}

void sendChatNotif(color) {
    def chat_message = "<${env.JOB_URL}|${env.JOB_NAME}>\n" +
        "#${env.BUILD_NUMBER}: freq=${env.freq}, timeout=${env.timeout}\n" +
        "${currentBuild.currentResult} " +
        "after ${currentBuild.durationString.replace(' and counting', '')} " +
        "(<${env.RUN_DISPLAY_URL}|See results>)"

    rocketSend attachments:
    [[$class: 'MessageAttachment',
      color: "$color",
      text: "$chat_message"]],
    channel: 'jenkins-analysis', rawMessage: true
}

void sendMailNotif(f, who) {
  if ( "$f" == "${env.freq}" ) {
    def msg = "${env.JOB_NAME} #${env.BUILD_NUMBER}: " +
      "${env.JOB_URL}#${env.BUILD_NUMBER}\n" +
      "freq=${env.freq} - timeout=${env.timeout}\n" +
      "${currentBuild.currentResult} " +
      "after ${currentBuild.durationString.replace(' and counting', '')}\n" +
      "Results: ${env.RUN_DISPLAY_URL}"
    def title = "[jenkins] ${env.JOB_NAME} (${env.freq})" +
                " - ${currentBuild.currentResult}"
    emailext subject: "$title",
             to: "${who}",
             replyTo: 'jenkins@trust-in-soft.com',
             body: "$msg"
  }
}
