A Step-by-Step Guide to Install Hadoop on OpenStack CentOS VMs and Run Jobs via Eclipse Hadoop Plugin. With Cluster Scalability.
=============================================================================================================================

Project Information
-------------------
-	Script license: Apache
-	Hadoop version: Hadoop 0.2
-	MapReduce version: MRv1
-	Binaries source for CentOS: Cloudera CDH4
-	Java version: Sun Java 1.7
-	OpenStack version: OpenStack Grizzly

Installation Steps
-------------------
Steps to install Hadoop on OpenStack CentOS VMs:

(1)	Git this repo

	:::
	yum install -y git
	git clone https://github.com/alrokayan/hadoop-openstack-easy.git
	cd hadoop-openstack-centos

(2)	From OpenStack Dashboard upload a CentOS image if you don't have one. You can download one from: http://c250663.r63.cf1.rackcdn.com/centos60_x86_64.qcow2

(3) Create 2 VMs, one master and one slave

(4) On both VMs: ``yum install -y git && git clone https://github.com/alrokayan/hadoop-openstack-easy.git && cd hadoop-openstack-centos``

(5) On master VM execute ``. 01-master.sh <MASTER NODE IP ADDRESS>``

(6) On slave VM execute ``. 02-slave-install.sh <MASTER NODE IP ADDRESS>``

(7) From OpenStack dashboard take a snapshot of the slave image and WAIT until it is completed

(8) Now you can provision as much machine as you want from that snapshot, and execute ``. 03-slave-start.sh`` on all of them.


Verification
-------------


Check Master Node
^^^^^^^^^^^^^^^^^

From the master node; execute this command to see if the master node (Name Node) is alive:

::

	sudo -u hdfs hadoop dfs -df

Check Salve Nodes
^^^^^^^^^^^^^^^^^

From the master node; execute this command to see if the new salve (Data Node) is running:

	:::
	sudo -u hdfs hadoop dfsadmin -report
	
Check HDFS Files
^^^^^^^^^^^^^^^^^
	
From the master node; execute this command to see all the files in HDFS:

	:::
	sudo -u hdfs hadoop fs -ls -R /


Execute Hadoop Job From Eclipse Plugin
--------------------------------------
You must be able to ssh to the master VM directly, not via OpenStack controller, you may use VPN.

(1) Login to the master node and execute (or have your own file):

	:::
	echo "test
	yes
	hadoop
	test
	no
	test
	no
	test
	" > text
	
	hadoop fs -copyFromLocal text /user/root/text

(2) In your computer that runs Eclipse, download *Hadoop Eclipse Plugin* from the last section in this page: http://wiki.apache.org/hadoop/EclipsePlugIn and place it in Eclipse plugin folder.

(3) Download Hadoop Jars (preferred stable): http://hadoop.apache.org/releases.html#Download and uncompress it, then place it in your home or C:\\ directory, or anywhere you like. 

(4)	Open Eclipse then choose: File -> New -> Project -> *MapReduce Project*.

(5)	Put any project name, then click ``Configure Hadoop install directory…``, then click ``Browse...`` and select your uncompressed Hadoop Jars folder, example: /Users/alrokayan/hadoop-0.22.0, then click Apply -> OK -> Finish.

(6)	Drag (or copy-and-past) the three .java files from ``Eclipse-Example`` folder (``WordCountDriver.java``, ``WordCountMap.java``, and ``WordCountReduce.java``) into the ``src`` folder (not the project it self) in Eclipse, then choose copy, then press OK.

(7)	From Eclipse: right-click on WorkCountDriver.java -> Run As -> Run On Hadoop with the following settings: 

	:::
	Hostname: <MASTER VM HOST IP ADDRESS>
	Installation directory: /usr/lib/hadoop
	Username: root
	Password: <MASTER VM PASSWORD>

(8) Login to the master node and execute: ``hadoop fs -cat /user/root/output/part-00000`` you should see:

	:::
	hadoop	1
	no	2
	test	4
	yes	1


Troubleshooting
----------------
*Error:*

::

	org.apache.hadoop.mapred.FileAlreadyExistsException

*Solutions:* (choose one of the two solutions):

-	Login to your client then delete the ``output`` (or what ever the name was) folder by executing the following command:

::

	hadoop fs -rm -r /user/root/output
-	Rename the output folder. For example: form WorkCountDriver.java by replace ``/user/root/output`` with ``/user/root/output1``.


-------

*Error:*

::
	
	–copyFromLocal: Unknown command  

*or*

::
	
	-cat: Unknown command

*Solution:* Retype the hyphen (-) from your keyboard in your terminal.

--------

*Error:*

::

	ERROR security.UserGroupInformation: PriviledgedActionException as:root

*Solution:* Delete all folders in HDFS then execute ``07-start-master/03-hdfs-system-folders.sh`` again. To delete folders in HDFS execute:

::

	sudo -u hdfs hadoop fs -rm -r /user
	sudo -u hdfs hadoop fs -rm -r /var
	sudo -u hdfs hadoop fs -rm -r /tmp

----------

*Error:*

::
	
	copyToLocal: `/user/root/text': No such file or directory

*Solution:* check if you want "copyToLocal" or "copyFromLocal", then ``ls`` local and HDFS folder. To ``ls`` HDFS do:

::

	hadoop fs -ls /path/to/folder

-----------

*Error:*

::

	Permission denied: user=root, access=WRITE, inode="/tmp/hadoop-mapred/mapred":hdfs:supergroup:drwxr-xr-x

*Solution:* Execute this command (Or what ever the folder):

::

	sudo -u hdfs hadoop fs -chmod 1777 /tmp/hadoop-mapred/mapred
	

------------

*Error:* Can't connect to: http://<OpenStack Controller IP/Hostname>:50030

or

::

	ERROR security.UserGroupInformation: PriviledgedActionException as:root (auth:SIMPLE) cause:java.net.ConnectException: Call From hadoop-client.novalocal/10.0.0.4 to hadoop-master:8021 failed on connection exception: java.net.ConnectException: Connection refused; For more details see:  http://wiki.apache.org/hadoop/ConnectionRefused


*Solution:* Login to the Master VM then run the JobTracker:

::

	service hadoop-0.20-mapreduce-jobtracker start


References
----------
- Cloudera CDH4 Installation Guide: https://ccp.cloudera.com/display/CDH4DOC/CDH4+Installation+Guide
- DAK1N1 Blog: http://dak1n1.com/blog/9-hadoop-el6-install