#!/bin/bash

NUMGPUS=$1
DATAPATH=$2
MODELPATH=$3
TRAINSTEPS=$4
JOB=$5
PSLIST=$6
WLIST=$7

PSNODES=$(echo $PSLIST | awk -F, '{ print NF }')
WNODES=$(echo $WLIST | awk -F, '{ print NF }')

CORRECTEDPSLIST=$(echo $PSLIST | sed -e 's/,/","/g')

echo "============" > log_env.txt
 
echo "$PSLIST" >> log_env.txt
echo "$WLIST" >> log_env.txt

echo "PS nodes: "$PSNODES >> log_env.txt
echo "Worker nodes: "$WNODES >> log_env.txt


MASTER=$(echo $WLIST | awk -F, '{ print $1 }')
echo "Master:"$MASTER >> log_env.txt
SLAVES=$(echo $WLIST | cut -d',' -f2-)
echo "Slaves:"$SLAVES >> log_env.txt
CORRECTEDWLIST=$(echo $SLAVES | sed -e 's/,/","/g')
echo "Corrected Slaves:"$CORRECTEDWLIST >> log_env.txt

NODENAME=$(echo $HOSTNAME | awk -F. '{print $1}')
NODEINDEX=$(echo $NODENAME| awk -F- '{print $2}')

echo "Nodename: "$NODENAME >> log_env.txt
echo "Node index: "$NODEINDEX >> log_env.txt
#It is a parameter server
if [ "$JOB" == "ps" ]
then
	#If there is just one worker, it is the master
	# The order of the ps is fine: ps-0,ps-1,...,ps-n
	# We can use the current index
	if [ $WNODES -eq 1 ]
	then
		export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIST'"]}, "task": {"type": "ps", "index": '$NODEINDEX'} }' 
	else
		export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIST'"], "worker": ["'$CORRECTEDWLIST'"]}, "task": {"type": "ps", "index": '$NODEINDEX'} }' #time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &
	fi
else
	#Otherwise, it is a worker
	#If there is just one worker, this is the master
	if [ $WNODES -eq 1 ]
	then
		MASTER=$WLIST
		export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIST'"]}, "task": {"type": "master", "index": 0} }' 
	else
		#More than one worker, deal with it
		# The index are correlative: ps-0,ps-1,...,ps-n,...,worker-m,worker-m+1,...
		# We should remove the number of ps from the current index
		CORRECTEDNODEINDEX=$(( NODEINDEX - PSNODES))
		
		#The first worker will be the master
		if [ "$JOB" == "worker" ] && [ "$CORRECTEDNODEINDEX" == "0" ]
		then
			WORKERJOB=master
			echo "Master: "$MASTER >> log_env.txt
			echo "Corrected worker index: "$CORRECTEDNODEINDEX >> log_env.txt
			export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIST'"], "worker": ["'$CORRECTEDWLIST'"]}, "task": {"type": "master", "index": 0} }' #time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &
		else
			#The rest are plain workers
			WORKERJOB=slave
			#Index correction, removing the master
			CORRECTEDNODEINDEX=$(( NODEINDEX - PSNODES - 1))
			echo "Corrected worker index: "$CORRECTEDNODEINDEX >> log_env.txt
			export TF_CONFIG='{ "environment": "cloud", "model_dir": "'$MODELPATH'", "cluster": { "master": ["'$MASTER'"], "ps": ["'$CORRECTEDPSLIST'"], "worker": ["'$CORRECTEDWLIST'"]}, "task": {"type": "'$JOB'", "index": '$CORRECTEDNODEINDEX'} }' #time python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log.txt 2>&1 &

		fi
	fi


fi




echo "Setting paths..."

export PATH=/usr/local/cuda/bin:/usr/local/bin:/opt/aws/bin:/home/ubuntu/src/cntk/bin:/usr/local/mpi/bin:$PATH
export LD_LIBRARY_PATH=/home/ubuntu/src/cntk/bindings/python/cntk/libs:/usr/local/cuda/lib64:/usr/local/lib:/usr/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/mpi/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PYTHONPATH=/home/ubuntu/src/cntk/bindings/python
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HDFS_HOME=/opt/hadoop-2.9.0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${JAVA_HOME}/jre/lib/amd64/server
export CLASSPATH=$(${HADOOP_HDFS_HOME}/bin/hadoop classpath --glob)

env >> log_env.txt

echo $TF_CONFIG >> log_env.txt

echo $LD_LIBRARY_PATH >> log_env.txt

if [ "$JOB" == "ps" ]
then
	echo "PS running in bg."
	python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log_"$HOSTNAME"_async.txt 2> err_"$HOSTNAME"_async.txt &
else
	if [ "$WORKERJOB" == "master" ]
	then
		echo "Master running async."
		python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log_"$HOSTNAME"_async.txt 2> err_"$HOSTNAME"_async.txt 
	else
		echo "Worker running in bg."
		python3 cifar10_main.py --data-dir=$DATAPATH --job-dir=$MODELPATH --num-gpus=$NUMGPUS --train-steps=$TRAINSTEPS > log_"$HOSTNAME"_async.txt 2> err_"$HOSTNAME"_async.txt &
	fi
fi