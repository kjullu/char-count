#import "../char-count.typ": char-count, char-count-of, total-characters-with-spaces

= Immediate count

#let sample = [Hello *Typst*!]
#let stats = char-count-of(sample)
#assert(stats.at("characters-with-spaces") == 12)

#sample contains #stats.at("characters-with-spaces") characters.

= Additional exclusions

#let filtered = char-count-of(
  [Keep #emph[omit]],
  exclude: emph,
)
#assert(filtered.at("characters-with-spaces") == 5)

= Complete-document count

// Everything after this rule contributes to the global total unless excluded.
#show: char-count

This section is counted.

Document total: #total-characters-with-spaces
