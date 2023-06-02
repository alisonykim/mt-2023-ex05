#! /bin/bash

scripts=$(dirname "$0")
base=$scripts/..

models=$base/models
configs=$base/configs
logs=$base/logs

mkdir -p $models
mkdir -p $logs

num_threads=4

model_ext="a b c" # Models to train

for ext in $model_ext; do
	model_name=transformer_$ext
	mkdir -p $logs/$model_name

	echo ""
	echo "###############################################################################"
	echo "now training model \"$model_name\""
	echo "###############################################################################"

	SECONDS=0

	OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/$model_name.yaml > $logs/$model_name/out 2> $logs/$model_name/err

	echo "time taken to train $model_name: $SECONDS sec"
done