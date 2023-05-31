# subword-nmt learn-joint-bpe-and-vocab --input {train_file}.de {train_file}.it -s {num_operations} -o {codes_file} --write-vocabulary {vocab_file}.de {vocab_file}.it
# apply to train, dev, test

# Path: scripts/apply_bpe.sh
# Data is found in data/{train,dev,test}.de-it.{de,it}
# Codes and vocab are found in data/bpe/codes.{de,it} and data/bpe/vocab.{de,it}

# check if bpe directory exists
if [ ! -d "data/bpe" ]; then
    mkdir data/bpe
fi

# learn BPE from concatenated training data
# create concatenated training data
cat data/processed/train.de-it.de.* data/processed/train.de-it.it.* > data/bpe/train.de-it.de-it
cat data/processed/train.de-it.it.* data/processed/train.de-it.de.* > data/bpe/train.de-it.it-de
# learn BPE
subword-nmt learn-joint-bpe-and-vocab --input data/bpe/train.de-it.de-it data/bpe/train.de-it.it-de -s 32000 -o data/bpe/codes.de-it --write-vocabulary data/bpe/vocab.de-it.de data/bpe/vocab.de-it.it
