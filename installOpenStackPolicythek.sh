#!/bin/sh
TAG="v1.2-alpha"
export SCRIPTPATH="https://raw.githubusercontent.com/OpenTOSCA/OpenTOSCA.github.io/$TAG"
export BINPATH="https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/$TAG"
echo "\n\nUsing tag: $TAG"
sh includeInstallCommon;
echo "\n\n### Install Policythek"
wget $BINPATH/Policythek.war;
sudo mv ./Policythek.war /var/lib/tomcat7/webapps/Policythek.war;
echo "\n\n### Fix BPS settings for OpenStack"
cd ~;
cp ~/wso2bps/repository/conf/carbon.xml ~/wso2bps/repository/conf/carbon.xml.bak
sed -i "s/<\!--HostName>www.wso2.org<\/HostName-->/<HostName>`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`<\/HostName>/g" ~/wso2bps/repository/conf/carbon.xml;
wget -qO- $SCRIPTPATH/includeInstallCommonStart | sh;
