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

