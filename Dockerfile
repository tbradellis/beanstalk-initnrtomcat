# Use an existing docker image with tomcat installed (official tomcat image -runs on linux debian)
#define the tomcat version so that we can control upgrade
FROM tomcat:8
LABEL maintainedby="bellisbkb"

# Install prepare infrastructure
RUN apt-get -y update && \
 apt-get -y install wget && \
 apt-get -y install tar

ENV CATALINA_HOME /usr/local/tomcat

#Add tomcat-users.xml with defined tomcat user.  Would like to add user to the existing xml on the container
#so that the additional asset isn't required - to-do list.
ADD tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml

#Create tomcat user
RUN groupadd -r tomcat && \
 useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
 chown -R tomcat:tomcat ${CATALINA_HOME}

WORKDIR /usr/local/tomcat

EXPOSE 8080
EXPOSE 8009

# Download New Relic Java Agent unpack and move to appropriate directory. Remove archive

RUN wget http://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java-3.41.0.zip && \
  unzip newrelic*.zip -d $CATALINA_HOME && \
  rm newrelic*.zip && \
  chown -R tomcat:tomcat $CATALINA_HOME/newrelic

#This works on docker run :docker run -e JAVA_OPTS="-javaagent:/usr/local/tomcat/newrelic/newrelic.jar -Dnewrelic.config.app_name=sndbx -Dnewrelic.config.license_key=yourNewReliclicensekey" initnrtomcat

#USER tomcat
RUN $CATALINA_HOME/bin/catalina.sh start
