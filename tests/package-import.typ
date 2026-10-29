#import "@local/char-count:0.3.0": char-count, char-count-of, total-characters-with-spaces

#assert(char-count-of([Package import]).at("characters-with-spaces") == 14)

#show: char-count

The local package import works.

Total: #total-characters-with-spaces
