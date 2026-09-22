# char-count

Count Unicode grapheme clusters and Danish normal pages in strings, Typst
content, or a complete document. One normal page is 2,400 characters including
spaces. Equations, citations, images, and other non-prose elements are ignored
by default.

```typ
#import "char-count.typ": char-count-of

#let count = char-count-of([Hello *Typst*!])
#count.at("characters-with-spaces") // 12
#count.at("normal-pages") // 0.005
```

## Install

Copy [`char-count.typ`](char-count.typ) into your project and import the
functions you need:

```typ
#import "char-count.typ": char-count, char-count-of, total-characters-with-spaces, total-normal-pages
```

When installed as a local Typst package, use:

```typ
#import "@local/char-count:0.1.0": char-count, char-count-of, total-characters-with-spaces, total-normal-pages
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
