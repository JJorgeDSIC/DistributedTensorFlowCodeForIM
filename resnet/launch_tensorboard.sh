#!/bin/bash

echo "Launching tensorboard..."

export LANG=en_US.UTF-8 LANGUAGE=en_US.en 
export LC_ALL=en_US.UTF-8

sleep 1m

MODELPATH=$1

tensorboard --logdir=$MODELPATH > tensorboard_log.txt 2>&1 &