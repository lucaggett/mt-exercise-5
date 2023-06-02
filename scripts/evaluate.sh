#! /bin/bash

scripts=$(dirname "$0")
base=$scripts/..

# get directory from command line argument
if [ $# -ne 3 ]; then
    echo "Usage: ./evaluate.sh <model_name> <source_lang> <target_lang>"
    exit 1
fi

model_name=$1
src=$2
trg=$3
data=$base/sampled_data
configs=$base/configs

translations=$base/translations

mkdir -p $translations

num_threads=4
device=0

# measure time

SECONDS=0

echo "###############################################################################"
echo "model_name $model_name"

translations_sub=$translations/$model_name

mkdir -p $translations_sub

CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name.yaml < $data/test.$src > $translations_sub/test.$model_name.$trg

# compute case-sensitive BLEU 

cat $translations_sub/test.$model_name.$trg | sacrebleu $data/test.$trg


echo "time taken:"
echo "$SECONDS seconds"
