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

// Missing fields must not match arbitrary requested values.
#assert(count([= Hello], exclude: heading.where(level: 2)) == 5)
#assert(count([Hello], exclude: text.where(size: 20pt)) == 5)
#assert(count([= Hello], exclude: heading.where(depth: 1)) == 0)
#assert(count(heading(level: 2)[Hello], exclude: heading.where(level: 2)) == 0)

// Both parts of a term item contribute, including nested formatting.
#assert(count(terms.item([Term], [Definition])) == 14)
#assert(count(terms.item([*Term*], [Definition])) == 14)
#assert(count(terms.item([Term], [Definition]), exclude: terms.item) == 0)
#assert(count(terms.item([*Term*], [Definition]), exclude: strong) == 10)

// Grapheme boundaries are independent of inline formatting.
#assert(count([a#text(fill: red)[́]]) == 1)
#assert(count([👨#text(fill: red)[‍👩‍👧‍👦]]) == 1)
#assert(count([a#emph[́]]) == count("á"))
#assert(normal-pages([a#emph[́]]) == 1 / 2400)
#assert(count([a#linebreak()#emph[́]]) == 3)

// Element functions that share a represented name are told apart.
#let lists = [- bullet
+ numbered]
#assert(count(lists, exclude: list.item) == 9)
#assert(count(lists, exclude: enum.item) == 7)
#assert(count(table([a], [b]), exclude: grid.cell) == 2)

// Grapheme clusters do not join across block boundaries.
#assert(count(table([a], [́])) == 2)
#assert(count(grid([a], [́])) == 2)
#assert(count([- a
- ́]) == 3)
#assert(count(terms.item([a], [́])) == 2)

// Excluded blocks still separate the text around them.
#assert(count([a#heading[x]́], exclude: heading) == 2)
#assert(char-count-of([a#footnote[x]́], footnotes: false).characters-with-spaces == 2)
#assert(count([a#figure[x]́]) == 2)

// Characters without spaces skip every whitespace cluster.
#let stats = char-count-of([Hello world

Again])
#assert(stats.characters-with-spaces == 18)
#assert(stats.characters-without-spaces == 15)
#assert(char-count-of("a b\tc").characters-without-spaces == 3)

// Footnotes count by default and can be turned off.
#assert(count([Text#footnote[Note]]) == 8)
#assert(char-count-of([Text#footnote[Note]], footnotes: false).characters-with-spaces == 4)

// Figures are excluded by default and can be turned on.
#let with-figure = [Before #figure([Body], caption: [Caption]) After]
#assert(count(with-figure) == 13)
#assert(char-count-of(with-figure, figures: true).characters-with-spaces == 24)

// Danish display helper.
#assert(format-danish(make-stats(12345, 0)) == "12.345\u{00A0}tegn · 5,14 normalsider")
#assert(format-danish(make-stats(2400, 0)) == "2.400\u{00A0}tegn · 1,00 normalsider")
#assert(format-danish(make-stats(2412, 0)) == "2.412\u{00A0}tegn · 1,01 normalsider")
#assert(format-danish(make-stats(23988, 0)) == "23.988\u{00A0}tegn · 10,00 normalsider")
#assert(format-danish(make-stats(120, 0), digits: 0) == "120\u{00A0}tegn · 0 normalsider")
#assert(format-danish(make-stats(1234567, 0), digits: 1) == "1.234.567\u{00A0}tegn · 514,4 normalsider")
#assert(format-danish(make-stats(12345, 0), thousands-separator: " ", separator: " – ") == "12 345\u{00A0}tegn – 5,14 normalsider")

All assertions passed.
