 FROM openjdk:21
 EXPOSE 8080
 ADD target/docker-integration.jar docker-integration.jar
 ENTRYPOINT ["java","-jar","/docker-integration.jar"]