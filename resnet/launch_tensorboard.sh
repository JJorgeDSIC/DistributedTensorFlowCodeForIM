#!/bin/bash

echo "Launching tensorboard..."

MODELPATH=$1

tensorboard --logdir=$MODELPATH &