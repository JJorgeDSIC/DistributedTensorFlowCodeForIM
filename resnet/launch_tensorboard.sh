#!/bin/bash
echo "Setting paths..."

export LD_LIBRARY_PATH=/home/ubuntu/src/cntk/bindings/python/cntk/libs:/usr/local/cuda/lib64:/usr/local/lib:/usr/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/mpi/lib:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server

echo "Launching tensorboard..."

export LANG=en_US.UTF-8 LANGUAGE=en_US.en 
export LC_ALL=en_US.UTF-8



MODELPATH=$1

tensorboard --logdir=$MODELPATH > tensorboard_log.txt 2>&1 &