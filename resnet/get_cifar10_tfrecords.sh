#!/bin/bash
export CUDA_VISIBLE_DEVICES=0

echo "Setting paths..."
source /etc/bash.bashrc

echo $LD_LIBRARY_PATH > log.txt

echo "Running downloading script"
python3 generate_cifar10_tfrecords.py --data-dir=/tmp/cifar-10-data/ >> log.txt