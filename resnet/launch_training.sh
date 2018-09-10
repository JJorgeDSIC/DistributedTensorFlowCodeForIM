#!/bin/bash


export CUDA_VISIBLE_DEVICES=0

time python3 cifar10_main.py --data-dir=/tmp/cifar-10-data --job-dir=/tmp/cifar-10-model --num-gpus=1 --train-steps=20000 > log.txt 2>&1 &