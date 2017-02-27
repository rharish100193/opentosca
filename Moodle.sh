#!/usr/bin
MySQLPort='3306'; MySQLUser='mdladmin'; MySQLPwd='mdladmin'; MySQLDB='moodledb'; MySQLRootPassword='highlySecureRootPasswort!'
sudo apt-get update
echo "# Installs MySQL and specifies credentials"
echo "mysql-server mysql-server/root_password password $MySQLRootPassword" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MySQLRootPassword" | sudo debconf-set-selections
sudo apt-get -y install mysql-server
echo "# Make MySQL available to the outside and restart"
sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
sudo service mysql restart
mysql -uroot -p$MySQLRootPassword -e "create user $MySQLUser;"
mysql -uroot -p$MySQLRootPassword -e "grant all privileges on *.* to '$MySQLUser'@'%' identified by '$MySQLPwd';"                       
mysql -uroot -p$MySQLRootPassword -e "create database $MySQLDB;"
sudo wget https://www.dropbox.com/s/6f4pafgpuvr6hcf/moodledb.sql
sudo chmod 777 ~/moodledb.sql
echo "Chmod over for moodledb.sql"
DbDumpFile=~/moodledb.sql
mysql -uroot -p$MySQLRootPassword $MySQLDB < $DbDumpFile
sudo apt-get update
sudo apt-get -y install apache2 php5 libapache2-mod-php5 php5-mysql curl
IPAddress=$(curl ipinfo.io/ip)
MoodleHost=$IPAddress; MySQLHost='127.0.0.1'; MoodleAdminUser='admin'; MoodleAdminPassword='moodle123'
echo "# Folders and files"
MoodleSiteName='moodle'; ApacheWWWDir='/var/www/html/'; MoodleInstallDir=$ApacheWWWDir$MoodleSiteName
MoodleDataDir=$ApacheWWWDir$MoodleSiteName'_data'; ConfigFileName='config.php'; ConfigFile=$MoodleInstallDir'/'$ConfigFileName
echo "# DB Data"
MySQLPort='3306'; MySQLUser='mdladmin'; MySQLPwd='mdladmin'; MySQLDB='moodledb'
echo "# Unzip"
sudo wget https://www.dropbox.com/s/oru7dp66cfuvi12/moodle-2.6.1.tgz
sudo mv moodle-2.6.1.tgz moodle.tgz
sudo tar -zxf ~/moodle.tgz -C $ApacheWWWDir
sudo wget https://www.dropbox.com/s/n3wkhkplllcsrr9/config.php
sudo chmod 777 ~/config.php
echo "Chmod over for config.php"
sudo mv ~/$ConfigFileName $ConfigFile
sudo mkdir $MoodleInstallDir -p
sudo chmod 755 $MoodleInstallDir -R
sudo mkdir $MoodleInstallDir/cache -p
sudo chmod 777 $MoodleInstallDir/cache -R
echo "# Create data dir"
sudo mkdir -p $MoodleDataDir
sudo chmod 777 $MoodleDataDir 
echo "# Configure moodle"
sudo sed -i "s/@MOODLE_HOST@/$MoodleHost/g" $ConfigFile
sudo sed -i "s/@MOODLE_SITE@/$MoodleSiteName/g" $ConfigFile
sudo sed -i "s/@MOODLE_ADMIN_USER@/$MoodleAdminUser/g" $ConfigFile
sudo sed -i "s/@DB_HOST@/$MySQLHost/g" $ConfigFile
sudo sed -i "s/@DB_PORT@/$MySQLPort/g" $ConfigFile
sudo sed -i "s/@DB_NAME@/$MySQLDB/g" $ConfigFile
sudo sed -i "s/@DB_USER@/$MySQLUser/g" $ConfigFile
sudo sed -i "s/@DB_PASSWORD@/$MySQLPwd/g" $ConfigFile
echo "# connect to DB and update Admin User, Admin Password and Site Name"
mysql -h$MySQLHost -P$MySQLPort -u$MySQLUser -p$MySQLPwd -D$MySQLDB -e "update mdl_config set value = '$MoodleDataDir/geoip/GeoLiteCity.dat' where name = 'geoipfile'; update mdl_config_log set value = '$MoodleDataDir/geoip/GeoLiteCity.dat' where name = 'geoipfile'; update mdl_course set fullname = '$MoodleSiteName', shortname = '$MoodleSiteName' where shortname = 'moodle'; update mdl_mnet_host set wwwroot = 'http://$MoodleHost/$MoodleSiteName', ip_address = '$MoodleHost', name = '$MoodleHost' where wwwroot = 'http://localhost/moodle'; update mdl_user set username = '$MoodleAdminUser', password = md5('$MoodleAdminPassword') where username = 'admin';"
sudo service apache2 restart