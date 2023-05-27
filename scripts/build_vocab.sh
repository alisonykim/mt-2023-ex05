#! /bin/bash

scripts=$(dirname "$0")
base=$scripts/..
data=$base/data
vocab=$base/vocab

mkdir -p $vocab

src=de
trg=nl

src_file=$data/train.$src-$trg.$src
trg_file=$data/train.$src-$trg.$trg

num_symbols="2000 10000"

for s in $num_symbols; do
	echo "Learning BPE for vocabulary size $s"
	
	SECONDS=0

	# Learn BPE
	subword-nmt learn-joint-bpe-and-vocab --input $src_file $trg_file --total-symbols -s $s -o $vocab/codes$s.bpe --write-vocabulary $vocab/vocab-$s-$src.txt $vocab/vocab-$s-$trg.txt

	# Concatenate DE and NL vocabulary files
	cat $vocab/vocab-$s-$src.txt $vocab/vocab-$s-$trg.txt > $vocab/vocab-$s-joint.txt

	# Remove token frequencies
	sed -i '' 's/ [0-9]*$//' $vocab/vocab-$s-joint.txt

	echo "time to finish: $SECONDS sec"
done