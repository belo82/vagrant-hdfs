#!/bin/sh


sed -i '$ a LC_ALL="en_US.UTF-8"' /etc/default/locale

apt-get update
apt-get install -y screen tmux htop mc pdsh

# Java
apt-get install -y python-software-properties debconf-utils
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
apt-get install -y oracle-java8-installer
echo 'JAVA_HOME="/usr/lib/jvm/java-8-oracle"' | sudo tee -a /etc/environment

### Create groups and users
groupadd -g 10000 hadoop

usermod -a -G hadoop ubuntu

useradd -G hadoop hdfs
mkhomedir_helper hdfs

useradd -G hadoop yarn
mkhomedir_helper yarn



### Install Core Hadoop
cd /usr/local
wget http://tux.rainside.sk/apache/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
tar xzvf hadoop-2.7.3.tar.gz
mkdir -p hadoop-2.7.3/logs
chown -R hdfs:hadoop hadoop-2.7.3
chmod g+rwx hadoop-2.7.3/logs
cat /vagrant/custom_profile >> /home/ubuntu/.profile



### Configure Hadoop DFS
mkdir -p /data/hadoop
mkdir -p /data/hadoop/dfs/name
mkdir -p /data/hadoop/dfs/namesecondary
mkdir -p /data/hadoop/dfs/data
chown -R hdfs:hadoop /data/hadoop

cp /vagrant/hadoop/etc/hadoop/* /usr/local/hadoop-2.7.3/etc/hadoop

### Setup passwordless SSH
# for user ubnutu
mkdir -p /home/ubuntu/.ssh
ssh-keygen -t rsa -P '' -f /home/ubuntu/.ssh/id_rsa
cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 0600 /home/ubuntu/.ssh/authorized_keys
cp /vagrant/ssh-config /home/ubuntu/.ssh/config


# for user hdfs
mkdir -p /home/hdfs/.ssh
ssh-keygen -t rsa -P '' -f /home/hdfs/.ssh/id_rsa
cat /home/hdfs/.ssh/id_rsa.pub >> /home/hdfs/.ssh/authorized_keys
chown -R hdfs:hdfs /home/hdfs/.ssh
chmod 0600 /home/hdfs/.ssh/authorized_keys
cp /vagrant/ssh-config /home/hdfs/.ssh/config

cat /vagrant/custom_profile >> /home/hdfs/.profile

# for user yarn
mkdir -p /home/yarn/.ssh
ssh-keygen -t rsa -P '' -f /home/yarn/.ssh/id_rsa
cat /home/yarn/.ssh/id_rsa.pub >> /home/yarn/.ssh/authorized_keys
chown -R yarn:yarn /home/yarn/.ssh
chmod 0600 /home/yarn/.ssh/authorized_keys
cp /vagrant/ssh-config /home/yarn/.ssh/config

cat /vagrant/custom_profile >> /home/yarn/.profile


### format namenode, socondary namenode and datanode (hdfs), resource manager and node manager (yarn)
export JAVA_HOME="/usr/lib/jvm/java-8-oracle"
sudo -u hdfs /usr/local/hadoop-2.7.3/bin/hdfs namenode -format

sudo -u hdfs /usr/local/hadoop-2.7.3/sbin/start-dfs.sh
sudo -u yarn /usr/local/hadoop-2.7.3/sbin/start-yarn.sh

### create home dir in HDFS for user ubuntu
sudo -u hdfs /usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /user
sudo -u hdfs /usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /user/ubuntu
sudo -u hdfs /usr/local/hadoop-2.7.3/bin/hadoop fs -chown -R ubuntu:hadoop /user/ubuntu
