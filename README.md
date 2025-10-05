IF you want to run then simply download this and run below command:->

mvn clean install

java -jar target/student-management-1.0.0.jar

access url:-> http://localhost:8080.

docker build -t student-management:1.0 .
docker run -d -p 8080:8080 student-management:1.0


structure:


student-management/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/devops/studentmanagement/
│   │   │       ├── StudentManagementApplication.java
│   │   │       ├── controller/StudentController.java
│   │   │       ├── model/Student.java
│   │   │       └── repository/StudentRepository.java
│   │   └── resources/
│   │       ├── templates/
│   │       │   ├── add-student.html
│   │       │   ├── edit-student.html
│   │       │   └── list-students.html
│   │       └── application.properties
│   └── test/
│       └── java/com/devops/studentmanagement/
│           └── StudentManagementApplicationTests.java
├── pom.xml
└── README.md

I have added jenkinsfile which will raise pull request so that manager can merge and it can deploy to argocd.

OR

We can directly push to master, below is the changes we will have to make.

                        git config --global user.name "Jenkins CI" 
                        git config --global user.email "jenkins@ci.local"
                        git checkout -b "PR-${IMAGE_TAG}"               ###remove this line
                        git add values.yaml
                        git commit -m "ci: bump image to ${IMAGE_TAG} (build ${BUILD_ID})" || echo "no changes to commit"
                        git push origin "PR-${IMAGE_TAG}"               ### this should be git push origin master
