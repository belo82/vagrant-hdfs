#HDFS & YARN

**Hadoop 2.7.3**

This directory contains Vagrant machine with HDFS, namenode, secondary namenode and data node 
running in pseudo distributed mode.

Namenode is configured to run on `localhost:9000`.

You can run `hadoop` commands after logging as user ubuntu. All commands are on your `PATH`.

Hadoop is installed in `/usr/local/hadoop-2.7.3`.
`hadoop.tmp.dir` points to `/data/hadoop/`. 
For exact configuration of Datanode and Namenode paths check out `hdfs-site.xml`

To start Hadoop DFS daemons run:

```
sudo -u hdfs /usr/local/hadoop-2.7.3/sbin/start-dfs.sh
```

To start all YARN daemons run:

```
sudo -u yarn /usr/local/hadoop-2.7.3/sbin/start-yarn.sh
```

To run map-reduce example run:

```
sudo su hdfs
cd /usr/local/hadoop-2.7.3

bin/hdfs dfs -put etc/hadoop input
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.3.jar grep input output 'dfs[a-z.]+'

# to check the result
bin/hdfs dfs -cat output/*
```