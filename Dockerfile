FROM arm32v7/openjdk:latest
MAINTAINER Sascha Deeg <sascha.deeg@gmail.com>
USER root
COPY ./target/demo-*.jar /root/demo.jar
EXPOSE 8080
CMD java -jar /root/demo.jar