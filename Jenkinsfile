pipeline {
  agent { label 'executor-v2' }

  environment {
    TEST_IMAGE = "conjur-cookbook-test:${env.GIT_COMMIT}"
  }

  stages {
    stage('Building test image') {
      steps {
        sh "./jenkins.sh build_test_image"
      }
    }
    stage('Lints and tests') {
      parallel {
        stage('Rubocop') {
          steps {
            sh "./jenkins.sh check_syntax"
            checkstyle pattern: 'ci/reports/rubocop.xml'
          }
        }
        stage('Foodcritic') {
          steps {
            sh "./jenkins.sh lint_cookbook"
          }
        }
        stage('Rspec') {
          steps {
            sh "./jenkins.sh run_specs"
            junit 'ci/reports/specs.xml'
          }
        }
        stage('Test kitchen') {
          steps {
            sh "summon -f secrets.ci.yml ./jenkins.sh test_kitchen"
          }
        }
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
