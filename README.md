# markov-chain

A markov chain trained on single-line text.

## Usage:

```haskell
stack build
stack exec -- markov-chain-exe <input file> <starting word> <number of words to generate>
```

Note that if the chain can't find any more words to go after while it's generating, then it'll stop prematurely and won't generate all of the words specified.

## Examples:

With an input file at `~/file.txt` with the contents
```
a b
b c
c d
```
and running with
```
stack exec -- markov-chain-exe ~/file.txt a 4
```
the program should print
```
a b c d
```

## Todo:

- Better error handling
- Better interface
