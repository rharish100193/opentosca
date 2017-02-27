#!/bin/sh
TAG="v1.2-alpha"
export SCRIPTPATH="https://raw.githubusercontent.com/OpenTOSCA/OpenTOSCA.github.io/$TAG"
export BINPATH="https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/$TAG"
echo "\n\n### AUTOMATICALLY INSTALLING OpenTOSCA"
echo "\n\n### Update Package List"
sudo apt-get -y update;
echo "\n\n### Install Java 7"
sudo apt-get -y install java7-jdk
echo "\n\n### Set JAVA_HOME"
sudo sh -c "echo 'JAVA_HOME=\"'$(readlink -f /usr/bin/java | sed "s:bin/java::")'\"' >> /etc/environment";
export JAVA_HOME="$(readlink -f /usr/bin/java | sed "s:bin/java::")";
echo "\n\n### Check Java Version"
javaversion=`$JAVA_HOME/bin/java -version 2>&1 | grep "1.[7|8]"`
if [ "$javaversion" = "" ]; then
   echo " \n\n\n\n########################################################\n"
   echo " PLEASE MAKE SURE THAT JAVA 1.7 or higher is installed!!!"
   echo " \n########################################################\n\n\n\n"
fi
echo "\n\n### Install Tomcat"
sudo apt-get -y install tomcat7 tomcat7-admin unzip;
sudo service tomcat7 stop;
echo "\n\n### Set CATALINA_OPTS"
sudo sh -c "echo 'CATALINA_OPTS=\"-Xms512m -Xmx1024m\"' >> /etc/default/tomcat7";
echo "\n\n### Tomcat User Settings"
cd ~;
wget $SCRIPTPATH/third-party/tomcat-users.xml;
wget $SCRIPTPATH/third-party/server.xml;
sudo mv ./tomcat-users.xml /var/lib/tomcat7/conf/tomcat-users.xml;
sudo mv ./server.xml /var/lib/tomcat7/conf/server.xml;
echo "\n\n### Install OpenTOSCAContainer.war"
wget $BINPATH/admin.war;
sudo mv ./admin.war /var/lib/tomcat7/webapps/admin.war;