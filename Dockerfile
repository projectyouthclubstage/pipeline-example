FROM armv7/armhf-java8:latest
MAINTAINER Sascha Deeg <sascha.deeg@gmail.com>

COPY ./target/demo-0.0.1-SNAPSHOT.jar /root/demo-0.0.1-SNAPSHOT.jar
EXPOSE 8080
CMD ["java","-jar /root/demo-0.0.1-SNAPSHOT.jar"]