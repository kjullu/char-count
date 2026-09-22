#import "../char-count.typ": *

#let count(content, exclude: ()) = char-count-of(content, exclude: exclude).at(
  "characters-with-spaces",
)

#let normal-pages(content, exclude: ()) = char-count-of(
  content,
  exclude: exclude,
).at("normal-pages")

#let mapped-count(content, exclude: ()) = (
  (map-tree(string-char-count, content, exclude: exclude),)
    .filter(result => result != none)
    .flatten()
    .fold(string-char-count(""), dictionary-sum)
    .at("characters-with-spaces")
)

#assert(count("") == 0)
#assert(count("abc") == 3)
#assert(count("á") == 1)
#assert(count("👨‍👩‍👧‍👦") == 1)
#assert(normal-pages("") == 0)
#assert(normal-pages("a" * 2400) == 1)
#assert(normal-pages("a" * 1200) == 0.5)

#assert(count([Hello world]) == 11)
#assert(count([*bold* and _emphasized_]) == 19)
#assert(count([a#linebreak()b]) == 3)
#assert(count([a#pagebreak()b]) == 6)
#assert(count([a

b]) == 4)
#assert(count(raw("raw text")) == 8)
#assert(count([#smartquote(double: true)quoted#smartquote(double: true)]) == 8)

#assert(count([keep #emph[omit]], exclude: emph) == 5)
#assert(count([keep #emph[omit]], exclude: "emph") == 5)
#assert(count([keep #emph[omit] <omitted>], exclude: <omitted>) == 6)
#assert(count([A #emph[B] #strong[C]], exclude: (emph, strong)) == 3)

#assert(count([= Ignored heading

Body]) == 21)
#assert(count([Before #figure[Hidden] After]) == 13)

#assert(
  count(
    [#heading(level: 1)[One] #heading(level: 2)[Two]],
    exclude: heading.where(level: 2),
  ) == 4,
)

#let sample-figure = figure([Body], caption: [Caption])
#assert(mapped-count(sample-figure) == 11)
#assert(mapped-count(sample-figure, exclude: ("figure-body",)) == 7)
#assert(mapped-count(sample-figure, exclude: ("caption",)) == 4)

All assertions passed.
