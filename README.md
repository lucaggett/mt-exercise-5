# MT Exercise 5: Byte Pair Encoding, Beam Search

## File structure and scripts

We made changes to the following files:
- scripts/train.sh
- scripts/evaluate.sh

We added the following files:
- scripts/create_apply_bpe.sh
- preprocess.ipynb

## Requirements
We used spacy to tokenize the data. To install spacy, run
```
pip install spacy
```

the code to download the required spacy model is already in the `preprocess.ipynb` notebook.

## Usage
### `create_apply_bpe.sh`
Note: This script requires that the data is already tokenized using preprocess.ipynb

`./create_bpe.sh <directory> <num_codes>`
This script creates a BPE model and applies it to the data. It takes the following arguments:
- `directory`: The directory to which the data should be saved (path: data/<directory>)
- `num_codes`: The number of BPE codes to use

### `train.sh`
We added some simple argument parsing to the `train.sh` script. It now takes the model name as an argument, and will automatically train a model using the .yaml file with the same name in the `configs` directory. the model will be saved to `models/<model_name>`

`./train.sh <model_name>`

### `evaluate.sh`
We added the same argument as for `train.sh` to the `evaluate.sh` script.

`./evaluate.sh <model_name>`

