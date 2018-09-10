#!/bin/bash

echo "Launching tensorboard..."

sleep 5m

MODELPATH=$1

tensorboard --logdir=$MODELPATH &