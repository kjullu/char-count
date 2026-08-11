#import "../char-count.typ": char-count, total-characters-with-spaces

#show: char-count

Hello

Total: #total-characters-with-spaces

#context assert(
  state("charometer").final().at("characters-with-spaces") == 19,
  message: "unexpected accumulated character count",
)
