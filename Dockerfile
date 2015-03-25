FROM tomcat:7-jre7
MAINTAINER Jeremy Villeneuve <jeremyv@halvanta.com>

# based on work by:
# MAINTAINER Leonard Daume <lenny@daume-web.eu>

# upgrade & install
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y libfreetype6 libfontconfig bzip2 subversion

# install maven
RUN wget http://apache.mirror.digionline.de/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz
RUN tar xvfz apache-maven-3.2.5-bin.tar.gz -C /opt
RUN rm -fv apache-maven-3.2.5-bin.tar.gz

RUN ln -s /opt/apache-maven-3.2.5/ /opt/apache-maven

ENV M2_HOME=/opt/apache-maven
ENV M2=$M2_HOME/bin
ENV PATH=$M2:$PATH

# install phantomjs
RUN curl -sSLO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
RUN tar xvjf phantomjs-1.9.8-linux-x86_64.tar.bz2 -C /opt
RUN rm -fv phantomjs-1.9.8-linux-x86_64.tar.bz2

RUN ln -s /opt/phantomjs-1.9.8-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs

ENV PHANTOM_BIN=/opt/phantomjs-1.9.8-linux-x86_64/bin
ENV PATH=$PHANTOM_BIN:$PATH

# install highcharts export server
RUN apt-get --yes --no-install-recommends install \
    openjdk-7-jdk \
  && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
RUN svn co https://github.com/highslide-software/highcharts.com/trunk/exporting-server/java/highcharts-export
RUN mvn -f ./highcharts-export/pom.xml install
RUN mvn -f ./highcharts-export/highcharts-export-web/pom.xml clean package
RUN cp highcharts-export/highcharts-export-web/target/highcharts-export-web.war webapps
RUN rm -rf highcharts-export


# Install Node.js
RUN apt-get update
RUN apt-get -y install python-software-properties git build-essential

# Install Node.js
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc



# RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
# RUN apt-get update
# RUN apt-get -y install python-software-properties git build-essential
# RUN add-apt-repository -y ppa:chris-lea/node.js
# RUN apt-get update
# RUN apt-get -y install nodejs
# RUN apt-get -y install npm


# Expose the node.js port (8081) to the Docker host and the highcharts port (8080)
EXPOSE 8080 8081


# Make the directory where the exported images will be stored
RUN mkdir /opt/chartimages

# Set the current working directory to the new mapped folder.
WORKDIR /opt/

# get the highcharts serverside render script
RUN svn co https://github.com/highslide-software/highcharts.com/trunk/exporting-server/phantomjs

# Copy in the phantomjs etcd file
COPY phantomjs /etc/init.d/


# modified from: https://github.com/robertschultz/docker-nodejs-hapi/blob/master/Dockerfile

# Add the current working folder as a mapped folder at /usr/src/app
ADD . /opt/highcharts-export-node-api

# Set the current working directory to the new mapped folder.
WORKDIR /opt/highcharts-export-node-api

# Install hapi framework for node.
RUN npm install hapi --save

# Copy in the node start file from the github repo
COPY node-highcharts-export-api.js /opt/highcharts-export-node-api/

# This is the stock express binary to start the app.
# CMD [ "node", "/opt/highcharts-export-node-api/node-highcharts-export-api.js" ]
CMD /usr/local/tomcat/bin/catalina.sh run & phantomjs /opt/phantomjs/highcharts-convert.js -host 127.0.0.1 -port 3003 & node /opt/highcharts-export-node-api/node-highcharts-export-api.js
