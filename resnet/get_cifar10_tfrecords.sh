#!/bin/bash
echo "Setting paths..."
$(cat /home/ubuntu/.bashrc | grep HADOOP_HOME)
$(cat /home/ubuntu/.bashrc | grep HADOOP_CONF_DIR)
$(cat /home/ubuntu/.bashrc | grep PATH)
$(cat /home/ubuntu/.bashrc | grep HADOOP_HDFS_HOME)
$(cat /home/ubuntu/.bashrc | grep JAVA_HOME)
$(cat /home/ubuntu/.bashrc | grep LD_LIBRARY_PATH)
$(cat /home/ubuntu/.bashrc | grep CLASSPATH)

echo $LD_LIBRARY_PATH > log_data.txt

echo "Running downloading script"
python3 generate_cifar10_tfrecords.py --data-dir=/tmp/cifar-10-data/ >> log_data.txt
