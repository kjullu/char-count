#import "../char-count.typ": char-count-of

// README and documentation examples.
#let readme = char-count-of([Hello *Typst*!])
#assert(readme.at("characters-with-spaces") == 12)
#assert(readme.at("normal-pages") == 12 / 2400)

#assert(char-count-of("á").at("characters-with-spaces") == 1)
#assert(char-count-of([Hello world]).at("characters-with-spaces") == 11)

#let body = [Keep #emph[omit]]
#assert(
  char-count-of(body, exclude: emph).at("characters-with-spaces") == 5,
)

#assert(
  char-count-of(
    [#heading(level: 1)[Keep] #heading(level: 2)[Omit]],
    exclude: heading.where(level: 2),
  ).at("characters-with-spaces") == 5,
)

Documentation examples compiled successfully.
