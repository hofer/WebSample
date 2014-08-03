FROM dockerfile/java
MAINTAINER Marc Hofer

ADD deploy/WebSample-SNAPSHOT.zip WebSample-SNAPSHOT.zip
RUN unzip WebSample-SNAPSHOT.zip

CMD cd WebSample && java -cp 'lib/*:.' ch.websample.WebSample

EXPOSE 8080