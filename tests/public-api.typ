#import "../char-count.typ": NORMAL_PAGE_CHARACTERS, char-count, char-count-of, final-stats, format-danish, total-characters-with-spaces, total-characters-without-spaces, total-normal-pages, total-summary

#assert(NORMAL_PAGE_CHARACTERS == 2400)
#assert(type(char-count) == function)
#assert(type(char-count-of) == function)
#assert(type(total-characters-with-spaces) == content)
#assert(type(total-normal-pages) == content)
#assert(type(total-characters-without-spaces) == content)
#assert(type(total-summary) == content)
#assert(type(final-stats) == function)
#assert(type(format-danish) == function)

The documented high-level API exports all its values.
