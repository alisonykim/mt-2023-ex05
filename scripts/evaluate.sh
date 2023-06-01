#! /bin/bash


scripts=$(dirname "$0")
base=$scripts/..

data=$base/data
configs=$base/configs
translations=$base/translations

mkdir -p $translations

src=de
trg=nl

num_threads=4
device=0

model_ext="a b c" # Models to evaluate

for ext in $model_ext; do
	model_name=transformer_$ext
	translations_sub=$translations/$model_name
	mkdir -p $translations_sub

	echo ""
	echo "###############################################################################"
	echo "now evaluating \"$model_name\""
	echo "###############################################################################"
	
	SECONDS=0
	
	# make predictions, write to file
	CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name.yaml < $data/test.$src-$trg.$src > $translations_sub/test.$model_name.$trg

	# delete first line: "sentence" is written to top of file, which messes up alignment for BLEU
	sed -i '' '1d' $translations_sub/test.$model_name.$trg
	
	# compute case-sensitive BLEU 
	cat $translations_sub/test.$model_name.$trg | sacrebleu $data/test.$src-$trg.$trg

	echo "time taken to evaluate $model_name: $SECONDS sec"
done