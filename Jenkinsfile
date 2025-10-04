// Jenkinsfile (Declarative)
pipeline {
  agent any

  environment {
    DOCKERHUB_USER = credentials('dockerhub-username')   // Jenkins credential (username)
    DOCKERHUB_PASS = credentials('dockerhub-password')   // Jenkins credential (password/token)
    GIT_CRED_ID    = 'git-credential'                    // Jenkins credential (username/password or token)
    IMAGE_NAME     = "student-management"
    DOCKERHUB_REPO = "${DOCKERHUB_USER}/${IMAGE_NAME}"
    CHART_PATH     = "student-management"           // path to helm chart in repo
    ARGO_HELM      = "https://github.com/vivekbagde1203/projectmp.git"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script { BRANCH = env.GIT_BRANCH ?: 'main' }
      }
    }

    stage('Build (Maven)') {
      steps {
        dir('backend') {
          sh 'mvn -B clean package -DskipTests'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // create image tag: use short git commit + build id
          GIT_SHORT = sh(script: "git rev-parse --short=8 HEAD", returnStdout: true).trim()
          IMAGE_TAG = "${GIT_SHORT}-${env.BUILD_ID}"
          env.IMAGE_TAG = IMAGE_TAG
        }
        dir('backend') {
          sh "docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} ."
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
        sh "docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}"
      }
    }

stage('Update Helm Chart') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'helm-repo-creds', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
            sh """
                git config user.email "jenkins@ci.local"
                git config user.name "Jenkins CI"                # Clone the Helm chart repo
                git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/vivekbagde1203/projectmp.git
                cd projectmp/${CHART_PATH}

                # Replace repository and tag in values.yaml
                sed -i '' "s|repository: .*|repository: \\"${DOCKERHUB_REPO}\\"|" ${CHART_PATH}/values.yaml
                sed -i '' "s|tag: .*|tag: \\"${IMAGE_TAG}\\"|" ${CHART_PATH}/values.yaml

                git add ${CHART_PATH}/values.yaml
                git commit -m "ci: bump ${IMAGE_NAME} image to ${IMAGE_TAG} (build ${BUILD_ID})" || echo "no changes to commit"
                git push origin main
            """
        }
    }
}


//    stage('Update Helm values & push') {
//      steps {
//        script {
//          // update values.yaml image.tag
//          sh """
//            git config user.email "jenkins@ci.local"
//            git config user.name "Jenkins CI"
//            git checkout ${ARGO_HELM}
//            sed -i  "s|repository: .*|repository: \"${DOCKERHUB_REPO}\"|" ${CHART_PATH}/values.yaml
//            sed -i  "s|tag: .*|tag: \"${IMAGE_TAG}\"|" ${CHART_PATH}/values.yaml
//            //yq eval -i '.image.repository = "${DOCKERHUB_REPO}"' ${CHART_PATH}/values.yaml
//            //yq eval -i '.image.tag = "${IMAGE_TAG}"' ${CHART_PATH}/values.yaml
//            git add ${CHART_PATH}/values.yaml
//            git commit -m "ci: bump ${IMAGE_NAME} image to ${IMAGE_TAG} (build ${env.BUILD_ID})" || echo "no changes to commit"
//            git push origin ${BRANCH}
//          """
//        }
//      }
//    }

    stage('Trigger ArgoCD Sync (optional)') {
      when {
        expression { return true } // keep or change to condition
      }
      steps {
        // Option A: call ArgoCD CLI (requires argocd CLI & creds on Jenkins agent)
        // Option B: rely on ArgoCD auto-sync on repo change (preferred)
        echo "If ArgoCD is watching this Git repo path it will sync automatically (or you can call argocd CLI here)."
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
    success {
      echo "Pipeline successful - ${DOCKERHUB_REPO}:${IMAGE_TAG}"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}

