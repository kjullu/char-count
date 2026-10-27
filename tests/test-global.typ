#import "../char-count.typ": char-count, final-stats, total-characters-with-spaces, total-characters-without-spaces, total-normal-pages, total-summary

#show: char-count

Hello

Total: #total-characters-with-spaces

Normal pages: #total-normal-pages

#context assert(
  state("charometer").final().at("characters-with-spaces") == 69,
  message: "unexpected accumulated character count: "
    + repr(state("charometer").final()),
)

#context assert(
  state("charometer").final().at("normal-pages")
    == state("charometer").final().at("characters-with-spaces") / 2400,
  message: "unexpected accumulated normal-page count: "
    + repr(state("charometer").final()),
)

Without spaces: #total-characters-without-spaces

Summary: #total-summary

#context assert(type(final-stats().characters-with-spaces) == int)
#context assert(
  final-stats().characters-without-spaces < final-stats().characters-with-spaces,
)
