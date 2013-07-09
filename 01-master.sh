#!/bin/sh

# Copyright 2012 Mohammed Alrokayan
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ $# -eq 1 ]
then

	# Same current location
	current_location=`pwd`
	
	yum update -y
	
	# Make new folder and go to it
	mkdir ~/install-java
	cd ~/install-java
	
	# download and install Java 1.6
	wget https://dl.dropbox.com/u/550719/PhD/jdk-6u37-linux-x64-rpm.bin
	chmod a+x jdk-6u37-linux-x64-rpm.bin
	./jdk-6u37-linux-x64-rpm.bin
	
	# Go back and delete the folder
	cd $current_location
	rm -rf ~/install-java
	
	# Show Java version
	java -version
	
	# Set Alternatives
	alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1600
	alternatives --auto java
	alternatives --display java
	
	# Disable SELINUX
	sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
	
	# Make new folder and go to it
	mkdir ~/install-CDH
	cd ~/install-CDH
	
	# download and install CDH
	wget http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.noarch.rpm
	yum install -y cloudera-cdh-4-0.noarch.rpm
	cd /etc/yum.repos.d/
	wget http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/cloudera-cdh4.repo
	rpm --import http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera
	
	# Go back and delete the folder
	cd $current_location
	rm -rf ~/install-CDH
	
	# Show the new CDH repo
	yum repolist
	
	# set the master IP address
	echo "$1 hadoop-master" >> /etc/hosts
	
	# Install master
	yum install -y hadoop-0.20-mapreduce-jobtracker hadoop-hdfs-namenode
	
	# Config Hadoop
	cp -r /etc/hadoop/conf.empty /etc/hadoop/conf.my_cluster
	alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.my_cluster/ 50
	alternatives --set hadoop-conf /etc/hadoop/conf.my_cluster/
	alternatives --display hadoop-conf
	
	# Copy conf files
	rm -f /etc/hadoop/conf/core-site.xml
	rm -f /etc/hadoop/conf/hdfs-site.xml
	rm -f /etc/hadoop/conf/mapred-site.xml

	cp conf/core-site.xml /etc/hadoop/conf/
	cp conf/hdfs-site.xml /etc/hadoop/conf/
	cp conf/mapred-site.xml /etc/hadoop/conf/
	
	# Set folders permission
	mkdir -p /hdfs/namenode
	mkdir -p /hdfs/datanode
	mkdir -p /hdfs/mapred
	chown -R hdfs:hadoop /hdfs/
	chown -R mapred:hadoop /hdfs/mapred/
	
	chgrp hdfs /usr/lib/hadoop-0.20-mapreduce/
	chmod g+rw /usr/lib/hadoop-0.20-mapreduce/

	# Set root password
	passwd
	
	# Formate HDFS
	sudo -u hdfs hadoop namenode -format
	
	# Start NameNode service
	service hadoop-hdfs-namenode start
	chkconfig hadoop-hdfs-namenode on
	
	# Start JobTracker Service
	service hadoop-0.20-mapreduce-jobtracker start
	chkconfig hadoop-0.20-mapreduce-jobtracker on
	
	# Create HDFS files
	sudo -u hdfs hadoop fs -mkdir /tmp
	sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
	sudo -u hdfs hadoop fs -mkdir /var
	sudo -u hdfs hadoop fs -mkdir /var/lib
	sudo -u hdfs hadoop fs -mkdir /var/lib/hadoop-hdfs
	sudo -u hdfs hadoop fs -mkdir /var/lib/hadoop-hdfs/cache
	sudo -u hdfs hadoop fs -mkdir /var/lib/hadoop-hdfs/cache/mapred
	sudo -u hdfs hadoop fs -mkdir /var/lib/hadoop-hdfs/cache/mapred/mapred
	sudo -u hdfs hadoop fs -mkdir /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
	sudo -u hdfs hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
	sudo -u hdfs hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred
	sudo -u hdfs hadoop fs -mkdir /tmp/hadoop-mapred/mapred/system
	sudo -u hdfs hadoop fs -chown mapred:hadoop /tmp/hadoop-mapred/mapred/system
	sudo -u hdfs hadoop fs -chmod 1777 /tmp/hadoop-mapred/mapred
	sudo -u hdfs hadoop fs -mkdir /user/root
	sudo -u hdfs hadoop fs -chown root /user/root

else
	echo "[ERROR] You must specify one argument: The IP address of the master node"
fi
