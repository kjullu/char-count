#import "../char-count.typ": char-count-of

= Count a passage

#let passage = [Hello *Typst*!]
#let stats = char-count-of(passage)

#passage contains #stats.at("characters-with-spaces") characters, including
spaces.
