# ------------------------------
# 1. Build stage
# ------------------------------
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set workdir
WORKDIR /app

# Copy pom.xml and download dependencies (layer caching optimization)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Package application
RUN mvn clean package -DskipTests

# ------------------------------
# 2. Runtime stage
# ------------------------------
FROM eclipse-temurin:17-jdk

# Set workdir
WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose default Spring Boot port
EXPOSE 8080

# Run the app
ENTRYPOINT ["java","-jar","app.jar"]

