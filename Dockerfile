FROM arm32v7/openjdk:11.0.3-slim-stretch
MAINTAINER Sascha Deeg <sascha.deeg@gmail.com>
USER root
RUN apt-get update
RUN apt-get install curl
COPY ./target/demo-*.jar /root/demo.jar
EXPOSE 8080
CMD java -jar /root/demo.jar
