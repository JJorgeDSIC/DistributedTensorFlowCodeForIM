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

if [ $WNODES -eq 0 ]
then
	TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$PSLIST'"]}, "task": {"type": "'$JOB'", "index": 0} }' time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &

else

	NODENAME=$(echo $HOSTNAME | awk -F. '{print $1}')
	NODEINDEX=$(echo $NODENAME| awk -F- '{print $2}')
	#It is a parameter server, the index is correct
	if [ "$JOB" == "ps" ]
	then
		TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$PSLIST'"], "worker": ["'$WLIST'"]}, "task": {"type": "'$JOB'", "index": '$NODEINDEX'} }' time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &

	else
		#It is the master node, the index is 0
		if [ "$JOB" == "master" ]
		then
			TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$PSLIST'"], "worker": ["'$WLIST'"]}, "task": {"type": "'$JOB'", "index": 0} }' time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &
		else
			#It is a worker, so the index is NODEINDEX-PSNODES-MNODES
			CORRECTEDNODEINDEX=$(( NODEINDEX - PSNODES - MNODES))
			TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$PSLIST'"], "worker": ["'$WLIST'"]}, "task": {"type": "'$JOB'", "index": '$CORRECTEDNODEINDEX'} }' time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &

		fi


	fi
fi

echo $TF_CONFIG