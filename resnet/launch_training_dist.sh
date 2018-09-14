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

if [ $WNODES -eq 0 ]
then
	export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIT'"]}, "task": {"type": "'$JOB'", "index": 0} }' 

else

	NODENAME=$(echo $HOSTNAME | awk -F. '{print $1}')
	NODEINDEX=$(echo $NODENAME| awk -F- '{print $2}')
	#It is a parameter server, the index is correct
	if [ "$JOB" == "ps" ]
	then
		export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIT'"], "worker": ["'$CORRECTEDWLIST'"]}, "task": {"type": "'$JOB'", "index": '$NODEINDEX'} }' #time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &

	else
		#It is the master node, the index is 0
		if [ "$JOB" == "master" ]
		then
			export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIT'"], "worker": ["'$CORRECTEDWLIST'"]}, "task": {"type": "'$JOB'", "index": 0} }' #time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &
		else
			#It is a worker, so the index is NODEINDEX-PSNODES-MNODES

			CORRECTEDNODEINDEX=$(( NODEINDEX - PSNODES - MNODES))
			export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIT'"], "worker": ["'$CORRECTEDWLIST'"]}, "task": {"type": "'$JOB'", "index": '$CORRECTEDNODEINDEX'} }' #time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &

		fi


	fi
fi

echo $TF_CONFIG > log_env.txt

echo "Setting paths..."
$(cat /home/ubuntu/.bashrc | grep HADOOP_HOME)
$(cat /home/ubuntu/.bashrc | grep HADOOP_CONF_DIR)
$(cat /home/ubuntu/.bashrc | grep PATH)
$(cat /home/ubuntu/.bashrc | grep HADOOP_HDFS_HOME)
$(cat /home/ubuntu/.bashrc | grep JAVA_HOME)
$(cat /home/ubuntu/.bashrc | grep LD_LIBRARY_PATH)
$(cat /home/ubuntu/.bashrc | grep CLASSPATH)

echo $LD_LIBRARY_PATH >> log_env.txt

nohup python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS >> log_"$HOSTNAME".txt 2> err_"$HOSTNAME".txt &