# char-count

Count Unicode grapheme clusters and Danish normal pages in strings, Typst
content, or a complete document. One normal page is 2,400 characters including
spaces. Equations, citations, images, and other non-prose elements are ignored
by default.

Counts describe source content, not final rendered output. Context-generated text
and show-rule replacements require special care; see [counting limits](docs/char-count.md#counting-limits).

```typ
#import "char-count.typ": char-count-of

#let count = char-count-of([Hello *Typst*!])
#count.at("characters-with-spaces") // 12
#count.at("normal-pages") // 0.005
```

## Count a whole document

```typ
#import "char-count.typ": char-count, final-stats, total-summary

// Count everything after this line, except block quotes and footnotes.
#show: char-count.with(exclude: quote, footnotes: false)

= My assignment

The text of the assignment goes here.

// Shows something like "12 345 tegn · 5,14 normalsider".
#total-summary

// Numbers you can calculate with, inside `context`.
#context calc.round(final-stats().normal-pages, digits: 1)
```

## Install

Copy [`char-count.typ`](char-count.typ) into your project and import the
functions you need:

```typ
#import "char-count.typ": char-count, char-count-of, final-stats, total-summary
```

When installed as a local Typst package, use:

```typ
#import "@local/char-count:0.1.0": char-count, char-count-of, final-stats, total-summary
```

The package is implemented entirely in Typst and has no runtime dependencies.

## Documentation

- [Documentation overview](docs/README.md)
- [`char-count-of`](docs/char-count-of.md) — count one string or content value
- [`char-count`](docs/char-count.md) — count a complete document with a show rule
- [Exclusions](docs/exclusions.md) — control which content is omitted
- [API reference](docs/api-reference.md) — every exported value and helper

A compilable example covering the complete public API is available in
[`examples/all-functions.typ`](examples/all-functions.typ). See the
[changelog](CHANGELOG.md) for release history.

## License

MIT
