#import "../char-count.typ": NORMAL_PAGE_CHARACTERS, char-count, char-count-of, total-characters-with-spaces, total-normal-pages

#assert(NORMAL_PAGE_CHARACTERS == 2400)
#assert(type(char-count) == function)
#assert(type(char-count-of) == function)
#assert(type(total-characters-with-spaces) == content)
#assert(type(total-normal-pages) == content)

The documented high-level API exports all four values.
