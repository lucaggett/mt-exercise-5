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

## BLEU-Scores

We have gotten the following BLEU-scores (beamsize for reference):

| use BPE | vocab size | BLEU | Beam-size |
| ------- | ---------- | -----|-----------|
| no      | 2000       | 6.8  | 5         |
| yes     | 2000       | 30.0 | 5         |
| yes     | 800        | tbd  | tbd       |

Before continuing further, I wish to note that the BPE-model with the reduced vocab size threw errors during training, which we have not yet resolved.

As we can see, using BPE for the same vocabulary size causes the BLEU score to shoot high in comparison. This rather clearly shows the advantage of using BPE in this specific case.
Reducing the vocabulary while still using BPE may lead to a slightly lower BLEU-score. It is reasonable to expect that a model using BPE still performs better than a model using word level vocabularies, since the handling of unseen tokens will be handled much better. We would definitely avoid sentences filled with "unk", even if those sentences may not be ideal.

When we look at the output that we got, we can easily see why the BLEU score of the non-BPE model is so bad. The first sentence is almost exclusively translated with "unk". Reading the text, it is practically impossible to figure out what is actually happening. Some words are repeated incredibly often, while all else is "unk", like in the example "unk come se unk questa macchina , una macchina unk , una macchina unk , una macchina unk , e questa è una unk ." We can figure out that there is some machine, it is impossible to know what the machine is for. In the first sentence of the BPE-model, there is also a crucial information missing. While we can figure out that Peter Skillman did come to give a TED-Talk, there is no mention of any sort of competition; the sentence is even grammatically incomplete. Additionally, the man's name is repeated - as in, written twice sequentially - which makes the sentence sound even more odd. There are multiple other sentences which are not complete, simply sound odd (like at some point the translation goes "velocemente rapidamente velocemente", which sounds very wrong) or are incomplete, be it grammatically or in information. All in all, the BPE model is way better, though in no way fully complete or correct. The 'machine sentence' that I quoted above sounds like that: "Quando avremmo fatto una macchina , una macchina , una grande macchina , una macchina , una macchina , TED--artista , e questa è una macchina ." This sentence is not entirely incomplete or non-informative, it just sounds much more like a song than anything else. The reference translation goes like this: "Facciamo finta di avere qui una macchina ,   grande , bellissima , in puro stile TED ,   è una macchina del tempo ." As you can see, both models focus way more on the word "machine" - which does occur more in German, but is not needed in Italian, especially not at the cost of losing the important information, which in this case lies in the adjectives. It is not surprising that this happened in the word-level model, but I am somewhat surprised that the BPE-model went over and simply ignored multiple adjectives, instead opting to prioritize the noun. 

Overall, the BPE-model offers more informative translations and does have a better and more Italian output, but it still sometimes fails to translate grammar correctly, or to reflect the entire scope of the input sentence in its translation. 

We have produced the following graphs to display what may change when using different beam sizes:

![Barplot showing the relation between beam size and bleu score, showing improvement from beamsize 1 to beamsize 5, then same bleu score for all higher numbers except for a lower bleu score for beam size 8 and beam size 10.](/src/beam_to_bleu_barplot.png "Beam to BLEU barplot").
![Lineplot showing the relation between beam size and bleu score, showing improvement from beamsize 1 to beamsize 5, then same bleu score for all higher numbers except for a lower bleu score for beam size 8 and beam size 10.](/src/beam_to_bleu_lineplot.png "Beam to BLEU lineplot").
![Barplot showing the relation between beam size and seconds to predict. Beam size 2 up until 10 all show that it takes continously more time to predict in direct proportion to the beam size. Beam size one is an exception, as it takes almost as much time to predict as beam size 6. ](/src/beam_to_seconds_barplot.png "Beam to seconds barplot").
![Lineplot showing the relation between beam size and seconds to predict. Beam size 2 up until 10 all show that it takes continously more time to predict in direct proportion to the beam size. Beam size one is an exception, as it takes almost as much time to predict as beam size 6.](/src/beam_to_seconds_lineplot.png "Beam to seconds lineplot").

While a higher beamsize shows to almost always increase the amount of time that it takes to predict, the same can not be said for the relation between beam size and BLEU score. From beam size 1 until beam size 5, the BLEU score constantly improves, but it seems to reach its limit with beam size five, as it either gets worse or stays the same for higher beam sizes. Interestingly, the seconds it takes for the lowest beam size 1 are only caught up to again with beam size 6. Beam size 5 performs better, in terms of time it takes and in performance via BLEU score, than those before and after.

We can thus see that a beam size of 5 would be ideal. In short, this is for the simple reason that any other beam sizes ending up with the same result - as in, the same BLEU score - take more time. 

You can find all code relevant for creating those graphs in our file `graphicals.ipynb`.

