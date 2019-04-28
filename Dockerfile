FROM hypriot/rpi-java:latest
MAINTAINER Sascha Deeg <sascha.deeg@gmail.com>
ARG TARGET_ARCH=arm-linux-user,aarch64-linux-user

COPY ./target/demo-0.0.1-SNAPSHOT.jar /root/demo-0.0.1-SNAPSHOT.jar
EXPOSE 8080
CMD ["java","-jar /root/demo-0.0.1-SNAPSHOT.jar"]