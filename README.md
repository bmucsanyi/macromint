# macromint

`macromint` is my standalone macro bundle.

It is independent of slide themes, figure styles, and conference templates. It
owns shared macros: alphabet commands, delimiters, generic operators, calculus
commands, recurring research notation, references, text abbreviations, and
theorem environments.

## Requirements

`macromint` supports LuaLaTeX, XeLaTeX, and pdfLaTeX. It does not load
`unicode-math` or `lua-unicode-math`. If a document or theme has already loaded
an OpenType math backend, alphabet commands use the active `\sym...` commands.
Otherwise, they use the standard LaTeX math alphabet commands from `mathtools`
and `amssymb`.

It does not set document fonts, colors, page layout, citation behavior, title
formatting, or figure styles. The document class and loaded style files own
those choices.

## Usage

Install the package into your user TeX tree from the repository root:

```sh
l3build install
```

Check that TeX can find the installed package:

```sh
kpsewhich macromint.sty
```

Then load the package directly:

```tex
\usepackage{macromint}
```

In a slide deck:

```tex
\documentclass[notheorems]{beamer}
\usetheme[palette = frappe]{slidemint}
\usepackage{macromint}
\usepackage{figmint}
```

In a paper:

```tex
\usepackage{neurips_2026}
\usepackage{macromint}
\usepackage{figmint}
```

In a paper that owns an OpenType math setup:

```tex
\usepackage{mathtools}
\usepackage[warnings-off={mathtools-colon,mathtools-overbracket}]{unicode-math}
\usepackage{macromint}
```

For arXiv, vendor the exact `macromint.sty` file
into the paper source tree.

## Scope

`macromint` owns shared macros. It does not depend on `slidemint` or `figmint`,
and they do not depend on it.

## Tests

Run from the repository root:

```sh
l3build check
```

## License

Apache 2.0.
