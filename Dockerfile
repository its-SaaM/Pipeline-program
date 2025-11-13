 FROM openjdk:21
 EXPOSE 8080
 ADD target/Docker-Integration.jar Docker-Integration.jar
 ENTRYPOINT ["java","-jar","/Docker-Integration.jar"]