#let dictionary-sum(a, b) = {
  let c = (:)
  for k in (a.keys() + b.keys()).dedup() {
    c.insert(k, a.at(k, default: 0) + b.at(k, default: 0))
  }
  c
}

#let string-char-count(string) = (
  characters-with-spaces: string.clusters().len(),
)

#let IGNORED_ELEMENTS = (
  "bibliography",
  "outline",
  "cite",
  "display",
  "equation",
  "h",
  "hide",
  "image",
  "line",
  "locate",
  "figure",
  "metadata",
  "path",
  "polygon",
  "ref",
  "repeat",
  "style",
  "update",
  "v",
)

#let parse-basic-where-selector(selector) = {
  let match = repr(selector).match(regex("^([\\w]+)\\.where(.*)$"))
  if match == none {
    panic("Only `element.where(key: value, ..)` selectors are supported.")
  }
  let (element-fn, fields) = match.captures
  (element-fn: element-fn, fields: eval(fields))
}

#let interpret-exclude-patterns(exclude) = {
  exclude.map(element-fn => {
    if type(element-fn) in (str, label, dictionary) { element-fn }
    else if type(element-fn) == function { repr(element-fn) }
    else if type(element-fn) == selector {
      parse-basic-where-selector(element-fn)
    } else {
      panic(
        "Exclude patterns must be element functions, strings, "
          + "selectors, or labels; got:",
        element-fn,
      )
    }
  })
}

#let map-tree(f, content, exclude: IGNORED_ELEMENTS) = {
  if content == none { return none }

  let exclude = interpret-exclude-patterns(exclude)
  let map-subtree = map-tree.with(f, exclude: exclude)

  let fn = repr(content.func())
  let fields = content.fields().keys()

  let exclude-selectors = exclude.filter(
    e => type(e) == dictionary and "element-fn" in e,
  )

  for (element-fn, wanted-fields) in exclude-selectors {
    if fn == element-fn {
      if not wanted-fields.pairs().any(
        ((key, value)) => content.at(key, default: value) != value,
      ) {
        return none
      }
    }
  }

  if fn in exclude {
    none
  } else if content.at("label", default: none) in exclude {
    none
  } else if fn in ("text", "raw") {
    f(content.text)
  } else if fn == "space" {
    f(" ")
  } else if fn == "linebreak" {
    f("\n")
  } else if fn == "parbreak" {
    f("\n\n")
  } else if fn == "pagebreak" {
    f("\n\n\n\n")
  } else if fn == "smartquote" {
    f(if content.double { "\"" } else { "'" })
  } else if "children" in fields {
    content.children
      .map(map-subtree)
      .filter(x => x != none)
  } else if fn == "figure" {
    (
      if "figure-body" not in exclude { map-subtree(content.body) },
      if "caption" in content.fields() and "caption" not in exclude {
        map-subtree(content.caption)
      },
    ).filter(x => x != none)
  } else if fn == "styled" {
    map-subtree(content.child)
  } else if "body" in fields {
    map-subtree(content.body)
  } else {
    none
  }
}

#let char-count-of(content, exclude: ()) = {
  if type(content) == str {
    return string-char-count(content)
  }

  let exclude = IGNORED_ELEMENTS + (exclude,).flatten()

  (map-tree(string-char-count, content, exclude: exclude),)
    .filter(x => x != none)
    .flatten()
    .fold(string-char-count(""), dictionary-sum)
}

#let global-total(field) = context {
  let stats = state("charometer").final()

  assert(
    stats != none,
    message: (
      "Global character count for " + field + " is not enabled.\n"
      + "Hint: Please add `#show: char-count` before the document."
    ),
  )

  assert(
    field in stats,
    message: (
      "Total " + repr(field)
      + " not found in character count result.\n"
      + "Hint: the counter returned " + repr(stats) + "."
    ),
  )

  stats.at(field)
}

#let total-characters-with-spaces = global-total(
  "characters-with-spaces",
)

#let char-count(content, exclude: ()) = {
  let stats = char-count-of(content, exclude: exclude)

  state("charometer").update(old-stats => {
    if old-stats == none { stats }
    else { dictionary-sum(old-stats, stats) }
  })

  content
}
