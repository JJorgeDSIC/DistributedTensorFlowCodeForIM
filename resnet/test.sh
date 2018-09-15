#!/bin/bash

NUMGPUS=$1
DATAPATH=$2
MODELPATH=$3
TRAINSTEPS=$4
JOB=$5
PSLIST=$6
MASTER=$7
WLIST=$8

CORRECTEDPSLIT=$(echo $PSLIST | sed -e 's/,/","/g')
CORRECTEDWLIST=$(echo $WLIST | sed -e 's/,/","/g')


export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIT'"]}, "task": {"type": "'$JOB'", "index": 0} }' 

echo "Setting paths..."

env > whole_env.txt

export LD_LIBRARY_PATH=/home/ubuntu/src/cntk/bindings/python/cntk/libs:/usr/local/cuda/lib64:/usr/local/lib:/usr/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/mpi/lib:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server

echo $TF_CONFIG > log_env.txt

echo $LD_LIBRARY_PATH >> log_env.txt

python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS

