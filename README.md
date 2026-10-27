# char-count

Version 0.2.0

Count the characters and Danish normal pages in a Typst document, so you can check an assignment against its length requirement without copying the text somewhere else.

It counts what a reader sees as one character, so `á` and `👨‍👩‍👧‍👦` each count as 1. Equations, citations, images, figures, and other non-prose content are left out by default. One normal page is 2,400 characters including spaces.

```typ
#import "char-count.typ": char-count, char-count-of, total-summary

#char-count-of([Hello *Typst*!])
// (characters-with-spaces: 12, characters-without-spaces: 11, normal-pages: 0.005)

// Count the rest of the document, without footnotes.
#show: char-count.with(footnotes: false)

= My assignment

The text of the assignment goes here.

#total-summary // for example "12 345 tegn · 5,14 normalsider"
```

The count covers the source text, not the rendered output. Text made inside `context` or by show rules is not counted. [Counting limits](docs/char-count.md#counting-limits) explains how to handle it.

## Install

Copy [`char-count.typ`](char-count.typ) into your project and import it:

```typ
#import "char-count.typ": char-count, char-count-of, final-stats, total-summary
```

Or install it as a local Typst package and use:

```typ
#import "@local/char-count:0.2.0": char-count, char-count-of, final-stats, total-summary
```

It needs Typst 0.14 or newer and has no dependencies.

## Documentation

- [Overview](docs/README.md) lists the main functions and the result fields.
- [`char-count-of`](docs/char-count-of.md) counts one string or piece of content, and shows how breaks and tables are counted.
- [`char-count`](docs/char-count.md) counts a whole document and shows the totals, rounded or as numbers.
- [Exclusions](docs/exclusions.md) covers the defaults and how to leave out more, like headings or labelled text.
- [API reference](docs/api-reference.md) lists every exported value, including low-level helpers.

[`examples/all-functions.typ`](examples/all-functions.typ) uses the whole public API in one file. Release history is in the [changelog](CHANGELOG.md).

## Testing

Compile each file in `tests/` from the repository root. A file passes if it compiles:

```sh
for f in tests/*.typ; do typst compile --root . "$f" /tmp/test.pdf; done
```

`tests/package-import.typ` needs the package installed as `@local/char-count:0.2.0`.

## License

MIT
