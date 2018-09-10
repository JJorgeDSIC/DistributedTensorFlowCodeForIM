#!/bin/bash
export CUDA_VISIBLE_DEVICES=0

NUMGPUS=$1
DATAPATH=$2
MODELPATH=$3
TRAINSTEPS=$4

time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &