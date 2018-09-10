#!/bin/bash
export CUDA_VISIBLE_DEVICES=0

NUMGPUS=$1
DATAPATH=$2
MODELPATH=$3
TRAINSTEPS=$4
JOB=$5
PSLIST=$6
MASTER=$7
WLIST=$8

TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ['$PSLIST'], "worker": ["'$WLIST'"]}, "task": {"type": "'$JOB'", "index": 0} }'

time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &