#!/bin/bash

NUMGPUS=$1
DATAPATH=$2
MODELPATH=$3
TRAINSTEPS=$4
JOB=$5
PSLIST=$6
MASTER=$7
WLIST=$8
PSNODES=$9
WNODES=$10

CORRECTEDPSLIT=$(echo $PSLIST | sed -e 's/,/","/g')
CORRECTEDWLIST=$(echo $WLIST | sed -e 's/,/","/g')


echo "Setting paths..."

export PATH=/usr/local/cuda/bin:/usr/local/bin:/opt/aws/bin:/home/ubuntu/src/cntk/bin:/usr/local/mpi/bin:$PATH
export LD_LIBRARY_PATH=/home/ubuntu/src/cntk/bindings/python/cntk/libs:/usr/local/cuda/lib64:/usr/local/lib:/usr/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/mpi/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PYTHONPATH=/home/ubuntu/src/cntk/bindings/python
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HDFS_HOME=/opt/hadoop-2.9.0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${JAVA_HOME}/jre/lib/amd64/server
export CLASSPATH=$(${HADOOP_HDFS_HOME}/bin/hadoop classpath --glob)

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

env > whole_env.txt

echo $TF_CONFIG > log_env.txt

echo $LD_LIBRARY_PATH >> log_env.txt

if [ "$JOB" == "ps" ]
then
	python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log_"$HOSTNAME"_async.txt 2> err_"$HOSTNAME"_async.txt &
else
	python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log_"$HOSTNAME"_async.txt 2> err_"$HOSTNAME"_async.txt 
fi