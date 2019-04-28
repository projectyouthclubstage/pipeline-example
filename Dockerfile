FROM armv7/armhf-java8:latest
MAINTAINER Sascha Deeg <sascha.deeg@gmail.com>
USER root
COPY ./target/demo-0.0.1-SNAPSHOT.jar /root/demo.jar
EXPOSE 8080
CMD java -jar /root/demo.jar