# GPOpen - Open-source grapheme-phoneme correspondence toolbox #

This toolbox accepts both word and non-word/pseudoword inputs, for simplicity, all inputs are refered to as words.
## Functions ##
### GPparser.m ###
This script uses the known phonology (phonlist) of a list of words (stimlist) to parse the words into graphemes and their corresponding phonemes. fix is a logical vector that will be true if the model detects an error parsing the word.

[graphemes,phonemes,fix] = GPparser(stimlist,phonlist);

### GPentropy.m ###
This script uses the graphemes and phonemes calculated by GPparser to calculate the entropy, grapheme probabilities and surprisal for the grapheme-to-phoneme conversion. Weighting is an optional input for weighting by word frequency ('freq'), position in the word ('pos'), or both factors ('freqpos').

[entropy,gprob,surprisal] = GPentropy(graphemes,phonemes,weighting);


### PGentropy.m ###
This script uses the graphemes and phonemes calculated by GPparser to calculate the entropy, phoneme probabilities and surprisal for the phoneme-to-grapheme conversion. Weighting is an optional input for weighting by word frequency ('freq'), position in the word ('pos'), or both factors ('freqpos').

[entropy,pprob,surprisal] = PGentropy(phonemes,graphemes,weighting);

### NGparser.m ###
This script attempts to parse words into graphemes without knowing their phonology. This uses the probabilities of occurence of multi-letter graphemes from a corpus of 33k words.

## Data Files ##
### GraphemePhoneme.csv ###
List of legal grapheme-phoneme correspondences used by the GPparser model

### GP_prob.mat ###
Precalculated grapheme-phoneme correspondence probabilities from a corpus of 33k words

### GG_prob.mat ###
Precalculated probabilities of multi-letter graphemes from a corpus of 33k words