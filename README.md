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

### BLEU-Scores

We have gotten the following BLEU-scores (beamsize for future reference):

| use BPE | vocab size | BLEU | Beam-size |
| ------- | ---------- | -----|-----------|
| no      | 2000       | 6.8  | 5         |
| yes     | 2000       | 30.0 | 5         |
| yes     | 800        |      |           |

As we can see, using BPE for the same vocabulary size causes the BLEU score to shoot high in comparison. This rather clearly shows the advantage of using BPE in this specific case.
Reducing the vocabulary while still using BPE ...

When we look at the output that we got, we can easily see why the BLEU score of the non-BPE model is so bad. The first sentence is almost exclusively translated with "unk". Reading the text, it is practically impossible to figure out what is actually happening. Some words are repeated incredibly often, while all else is "unk", like in the example "<unk> come se <unk> questa macchina , una macchina <unk> , una macchina <unk> , una macchina <unk> , e questa è una <unk> ." We can figure out that there is some machine, it is impossible to know what the machine is for. In the first sentence of the BPE-model, there is also a crucial information missing. While we can figure out that Peter Skillman did come to give a TED-Talk, there is no mention of any sort of competition; the sentence is even grammatically incomplete. Additionally, the man's name is repeated - as in, written twice sequentially - which makes the sentence sound even more odd. There are multiple other sentences which are not complete, simply sound odd (like at some point the translation goes "velocemente rapidamente velocemente", which sounds very wrong) or are incomplete, be it grammatically or in information. All in all, the BPE model is way better, though in no way fully complete or correct. The 'machine sentence' that I quoted above sounds like that: "Quando avremmo fatto una macchina , una macchina , una grande macchina , una macchina , una macchina , TED--artista , e questa è una macchina ." This sentence is not entirely incomplete or non-informative, it just sounds much more like a song than anything else. The reference translation goes like this: "Facciamo finta di avere qui una macchina ,   grande , bellissima , in puro stile TED ,   è una macchina del tempo ." As you can see, both models focus way more on the word "machine" - which does occur more in German, but is not needed in Italian, especially not at the cost of losing the important information, which in this case lies in the adjectives. It is not surprising that this happened in the word-level model, but I am somewhat surprised that the BPE-model went over and simply ignored multiple adjectives, instead opting to prioritize the noun. 

Overall, the BPE-model offers more informative translations and does have a better and more Italian output, but it still sometimes fails to translate grammar correctly, or to reflect the entire scope of the input sentence in its translation. 

