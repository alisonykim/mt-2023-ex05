#! /bin/bash


scripts=$(dirname "$0")
base=$scripts/..

data=$base/data
configs=$base/configs
translations=$base/translations
translations_logs=$translations/logs

mkdir -p $translations
mkdir -p $translations_logs

src=de
trg=nl

num_threads=4
device=0

model_name="transformer_c"

beam_sizes="2 3 4 5 6 7 8 10 12 15 20"

for k in $beam_sizes; do
	# Create temporary config file with specified beam size `k`
	python scripts/modify_k.py --model $model_name --beam-size $k

	# Define directory in which translations will be stored
	translations_sub=$translations/$model_name
	mkdir -p $translations_sub

	# Perform inference
	echo ""
	echo "###############################################################################"
	echo "now performing inference with model \"$model_name\", beam size $k"
	echo "###############################################################################"

	SECONDS=0
	
	CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name\_$k.yaml < $data/test.$src-$trg.$src > $translations_sub/hyps.$k.$trg
	
	# Delete first line: "sentence" is written to top of file, which messes up alignment for BLEU
	sed -i '' '1d' $translations_sub/hyps.$k.$trg

	# Calculate BLEU, write to log file
	cat $translations_sub/hyps.$k.$trg | sacrebleu $data/test.$src-$trg.$trg > $translations_logs/hyps.$k.log

	# Append time to log file
	echo ""
	echo "Time taken (seconds): $SECONDS"
	echo "Time taken (seconds): $SECONDS" >> $translations_logs/hyps.$k.log

	# Delete temporary config file
	rm $configs/$model_name\_$k.yaml
done