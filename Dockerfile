 FROM openjdk:21
 EXPOSE 8080
 ADD target/dockerintegration.jar dockerintegration.jar
 ENTRYPOINT ["java","-jar","/dockerintegration.jar"]