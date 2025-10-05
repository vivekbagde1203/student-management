pipeline {
    agent any
    tools {
        jdk 'java17'
        maven 'maven3'
    }
    environment {
      DOCKER_CRED_ID = 'dockerhub'    // Jenkins credential (username)
      GIT_CRED_ID    = 'git-credential'                    // Jenkins credential (username/password or token)
      APP_NAME       = "student-management"
      DOCKERHUB_USER = "projectdocker1203"
      IMAGE_TAG      = "v1.0.${BUILD_NUMBER}"
      IMAGE_NAME     = "${DOCKERHUB_USER}" + "/" + "${APP_NAME}"
      CHART_PATH     = "student-management"           // path to helm chart in repo
      ARGO_HELM      = "https://github.com/vivekbagde1203/projectmp.git"
    }
    stages {
        stage('git checkout') {
            steps {
                git branch: 'master', credentialsId: 'git-credential', url: 'https://github.com/vivekbagde1203/student-management.git'
            }
        }
        stage("Build Application"){
            steps {
                sh "mvn clean package"
            }

        }
        stage("Test Application"){
            steps {
                sh "mvn test"
            }

        }
        stage("Build & Push Docker Image") {
            steps {
                script {
                    docker.withRegistry('',DOCKER_CRED_ID) {
                        docker_image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        docker_image.push("${IMAGE_TAG}")
                    }

                    //docker.withRegistry('',DOCKER_PASS) {
                    //    docker_image.push("${IMAGE_TAG}")
                    //    docker_image.push('latest')
                    //}
                }
            }
        }
        stage('Update Helm Chart') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'git-credential', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    sh '''
                        git config user.email "jenkins@ci.local"
                        git config user.name "Jenkins CI"                # Clone the Helm chart repo
                    # Clean folder if it exists
                    if [ -d "projectmp" ]; then
                        rm -rf projectmp
                    fi
                        git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/vivekbagde1203/projectmp.git
                        cd projectmp/${CHART_PATH}
                        ls -ltrah

                        # Replace repository and tag in values.yaml
                        sed -i "s|repository: .*|repository: \\"projectdocker1203/student-management\\"|" values.yaml
                        sed -i "s|tag: .*|tag: \\"${IMAGE_TAG}\\"|" values.yaml
                        
                        git config --global user.name "Jenkins CI" 
                        git config --global user.email "jenkins@ci.local"
                        git checkout -b "PR-${IMAGE_TAG}"
                        git add values.yaml
                        git commit -m "ci: bump image to ${IMAGE_TAG} (build ${BUILD_ID})" || echo "no changes to commit"
                        git push origin "PR-${IMAGE_TAG}"
                    '''
                }
            }
        }
stage('Approve PR') {
    steps {
        withCredentials([string(credentialsId: 'git-credential', variable: 'GIT_TOKEN')]) {
            sh '''
                gh auth login --with-token <<< $GIT_TOKEN
                PR_NUMBER=$(gh pr list --repo vivekbagde1203/projectmp --state open --json number --jq '.[0].number')
                gh pr review $PR_NUMBER --approve --repo vivekbagde1203/projectmp
            '''
        }
    }
}

        //}
        stage("Cleanup Workspace"){
            steps {
                cleanWs()
            }

        }
    }
}

