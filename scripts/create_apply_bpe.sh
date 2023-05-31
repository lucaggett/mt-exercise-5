# Path: scripts/apply_bpe.sh
# Data is found in data/{train,dev,test}.de-it.{de,it}
# Codes and vocab are found in data/$directory/codes.{de,it} and data/$directory/vocab.{de,it}

# Get arguments (directory and number of codes)
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: ./create_bpe.sh <directory> <num_codes>"
    exit 1
fi
if [ $# -eq 1 ]; then
    num_codes=2000
    echo "Using default number of codes: 2000"
else
    num_codes=$2
    echo "Using number of codes: $num_codes"
fi
if [ $# -eq 2 ]; then
    directory=$1
    echo "Using directory: $directory"
else
    directory="bpe_$num_codes"
    echo "Using default directory: $directory"
fi

# check if bpe directory exists
if [ ! -d "data/$directory" ]; then
    mkdir data/$directory
    echo "Created directory data/$directory"
fi

# learn BPE from concatenated training data
# create concatenated training data
cat data/processed/train.de-it.de.* data/processed/train.de-it.it.* > data/$directory/train.de-it.de-it
cat data/processed/train.de-it.it.* data/processed/train.de-it.de.* > data/$directory/train.de-it.it-de
# learn BPE only if codes file does not exist
if [ ! -f "data/$directory/codes.de-it" ]; then
    subword-nmt learn-joint-bpe-and-vocab --input data/$directory/train.de-it.de-it data/$directory/train.de-it.it-de -s $num_codes -o data/$directory/codes.de-it --write-vocabulary data/$directory/vocab.de-it.de data/$directory/vocab.de-it.it
fi
echo "BPE learned"
# apply BPE to train, dev and test
for lang in de it; do
    for split in train dev test; do
        subword-nmt apply-bpe -c data/$directory/codes.de-it --vocabulary data/$directory/vocab.de-it.$lang --vocabulary-threshold 50 < data/processed/$split.de-it.$lang.tokenized > data/$directory/$split.de-it.$lang.bpe
        echo "BPE applied to $split.$lang"
        echo "saved in data/$directory/$split.de-it.$lang.bpe"
    done
done

# create combined vocab if it does not exist
if [ ! -f "data/$directory/combined_vocab.txt" ]; then
    cat data/$directory/vocab.de-it.de data/$directory/vocab.de-it.it > data/$directory/combined_vocab.txt
    # remove counts
    awk '{print $1}' data/$directory/combined_vocab.txt > data/$directory/combined_vocab.txt.tmp && mv data/$directory/combined_vocab.txt.tmp data/$directory/combined_vocab.txt
fi

# rename files
for lang in de it; do
    for split in train dev test; do
        mv data/$directory/$split.de-it.$lang.bpe data/$directory/$split.$lang
    done
done