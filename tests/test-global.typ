#import "../char-count.typ": char-count, total-characters-with-spaces, total-normal-pages

#show: char-count

Hello

Total: #total-characters-with-spaces

Normal pages: #total-normal-pages

#context assert(
  state("charometer").final().at("characters-with-spaces") == 37,
  message: "unexpected accumulated character count: "
    + repr(state("charometer").final()),
)

#context assert(
  state("charometer").final().at("normal-pages")
    == state("charometer").final().at("characters-with-spaces") / 2400,
  message: "unexpected accumulated normal-page count: "
    + repr(state("charometer").final()),
)
