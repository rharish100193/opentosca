#!/bin/sh
TAG="v1.2-alpha"
export SCRIPTPATH="https://raw.githubusercontent.com/OpenTOSCA/OpenTOSCA.github.io/$TAG"
export BINPATH="https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/$TAG"
echo "\n\nUsing tag: $TAG"
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
echo "\n\n### Install ROOT.war"
wget $BINPATH/ROOT.war;
sudo rm /var/lib/tomcat7/webapps/ROOT -fr;
sudo mv ./ROOT.war /var/lib/tomcat7/webapps/ROOT.war;
echo "\n\n### Install admin.war"
wget $BINPATH/admin.war;
sudo mv ./admin.war /var/lib/tomcat7/webapps/admin.war;
wget $BINPATH/OpenTOSCAUi.war
sudo mv ./OpenTOSCAUi.war /var/lib/tomcat7/webapps/OpenTOSCAUi.war
echo "\n\n### Install vinothek.war"
wget $BINPATH/vinothek.war;
sudo mv ./vinothek.war /var/lib/tomcat7/webapps/vinothek.war;
echo "\n\n### Install Winery"
wget $SCRIPTPATH/third-party/winery.war
wget $SCRIPTPATH/third-party/winery-topologymodeler.war
sudo mv ./winery.war /var/lib/tomcat7/webapps/winery.war;
sudo mv ./winery-topologymodeler.war /var/lib/tomcat7/webapps/;
echo "\n\n### Import Winery Repository (into home)"
sudo mkdir /usr/share/tomcat7/winery-repository;
wget $SCRIPTPATH/third-party/winery-repository.zip;
sudo unzip -qo winery-repository.zip -d /usr/share/tomcat7/winery-repository;
sudo chown -R tomcat7:tomcat7 /usr/share/tomcat7/winery-repository;
echo "\n\n### Install OpenTOSCAContainer.war"
wget https://www.dropbox.com/s/e9peufpl69aas19/OpenTOSCAContainer.war; 
sudo mv ./OpenTOSCAContainer.war /var/lib/tomcat7/webapps/OpenTOSCAContainer.war;
sudo mkdir /home/ubuntu/keyDB;
sudo chmod -R 777 /home/ubuntu/keyDB;
sudo service tomcat7 start;
