 FROM openjdk:21-jdk
 EXPOSE 8080
 ADD target/dockerintegration.jar dockerintegration.jar
 ENTRYPOINT ["java","-jar","/dockerintegration.jar"]