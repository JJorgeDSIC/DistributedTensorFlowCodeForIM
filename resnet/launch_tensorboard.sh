#!/bin/bash
echo "Setting paths..."

export PATH=/usr/local/cuda/bin:/usr/local/bin:/opt/aws/bin:/home/ubuntu/src/cntk/bin:/usr/local/mpi/bin:$PATH
export LD_LIBRARY_PATH=/home/ubuntu/src/cntk/bindings/python/cntk/libs:/usr/local/cuda/lib64:/usr/local/lib:/usr/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/mpi/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PYTHONPATH=/home/ubuntu/src/cntk/bindings/python
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HDFS_HOME=/opt/hadoop-2.9.0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${JAVA_HOME}/jre/lib/amd64/server
export CLASSPATH=$(${HADOOP_HDFS_HOME}/bin/hadoop classpath --glob)

echo "Launching tensorboard..."

export LANG=en_US.UTF-8 LANGUAGE=en_US.en 
export LC_ALL=en_US.UTF-8


MODELPATH=$1

tensorboard --logdir=$MODELPATH > tensorboard_log.txt 2>&1 &