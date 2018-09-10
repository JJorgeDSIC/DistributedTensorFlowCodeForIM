#!/bin/bash

echo "Launching tensorboard..."
tensorboard --logdir=hdfs://default/cifar-10-model &