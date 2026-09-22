#import "../char-count.typ": char-count, char-count-of

// Context output is opaque to immediate source-content counting.
#assert(char-count-of(context [Hello]).at("characters-with-spaces") == 0)

// Count context output explicitly once, and combine it with an ordinary body.
#char-count([a#emph[́]])
#context {
  let resolved = [Hello]
  char-count(resolved)
}
#context assert(state("charometer").final().at("characters-with-spaces") == 6)
#context assert(state("charometer").final().at("normal-pages") == 6 / 2400)
