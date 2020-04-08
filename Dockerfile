FROM openjdk:8

COPY target/hello-world-maven-*.jar /opt/iti/
CMD java -jar /opt/iti/hello-world-maven-*.jar
