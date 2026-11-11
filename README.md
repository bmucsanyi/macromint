# macromint

`macromint` is my LaTeX macro bundle for papers and slide decks.

## Requirements

LuaLaTeX, XeLaTeX, or pdfLaTeX,
`mathtools`, and `xspace`. `amsthm` is loaded unless the class brings its own
`proof` environment, as `jmlr` and `llncs` do.

## Installation

From the repository root:

```sh
l3build install
```

This installs `macromint.sty` into the user TeX tree, where `kpsewhich
macromint.sty` finds it. For arXiv, vendor the file into the paper source.

## Usage

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

In a paper that installs the paper math stack:

```tex
\usepackage{neurips_2026}
\usepackage{papermint}
\usepackage{macromint}
\usepackage{figmint}
```

In a paper that owns its math setup:

```tex
\usepackage{mathtools}
\usepackage[warnings-off={mathtools-colon,mathtools-overbracket}]{unicode-math}
\usepackage{macromint}
```

Under `jmlr`, which defines `\set` as `\mathcal`, do this:

```tex
\documentclass{jmlr}
\let\set\relax
\usepackage{macromint}
```

### Bold symbols

A bold symbol has the shape it has at normal weight, on every engine. Latin
letters and lower-case Greek are bold italic: `\bx` is $\boldsymbol{x}$ and
`\btheta` is $\boldsymbol{\theta}$. Upper-case Greek and digits are bold
upright: `\bTheta`, `\bzero`. The thirteen Greek capitals that share a Latin
shape, `\bAlpha`, `\bBeta`, `\bEpsilon`, `\bZeta`, `\bEta`, `\bIota`,
`\bKappa`, `\bMu`, `\bNu`, `\bOmicron`, `\bRho`, `\bTau`, and `\bChi`, are
bold upright as well. Under `unicode-math` this holds whatever `bold-style`
the document selects.

### Theorem environments

`macromint` provides `theorem`, `proposition`, `lemma`, `corollary`,
`definition`, `assumption`, `problem`, and `remark`. Each is defined at load
only where the class or an earlier package has not defined it, so a class with
its own theorem environments keeps them, and `macromint` adds the missing ones
on the `theorem` counter. Where `macromint` defines `theorem`, it is numbered
within sections. The preamble may use the `theorem` counter, as in
`\newtheorem{conjecture}[theorem]{Conjecture}`. The amsthm styles `plain`,
`definition`, and `remark` are selected where `\theoremstyle` exists.

## Public interface

Alphabets:

- `\ba` to `\bz` and `\bA` to `\bZ`, bold Latin letters, with `\bff` for f and
  `\bmm` for m; `\bzero` and `\bone`.
- `\balpha` to `\bomega` and `\bAlpha` to `\bOmega`, bold Greek letters, with
  `\beeta` for eta.
- `\nA` to `\nZ`, blackboard bold letters, and `\E` and `\R`.
- `\cA` to `\cZ`, calligraphic letters.

Relations and delimiters:

- `\defeq`, `\rdefeq`.
- `\set{x \in X \where P(x)}` and `\set{x \in X \suchthat P(x)}`, with `\where`
  typeset as a colon and `\suchthat` as a bar. `\where` and `\suchthat` are
  errors outside `\set`.
- `\abs`, `\norm`, `\card`, `\ceil`, `\floor`, and `\inprod{x}{y}`.
- Every delimiter takes the size through an optional argument, `\abs[\big]{x}`,
  and scales to its content without it.

References: `\figref`, `\secref`, `\eqnref`, `\tabref`.

Operators: `\argmax`, `\argmin`, `\softmax`, `\sgn`, `\Bias`, `\Var`, `\Cov`,
`\diag`, `\Perplexity`, `\rank`, `\KL`.

Functions: `\domain`, `\range`, `\kernel`, `\linspan`, `\trace`, `\boundaryof`,
`\closureof`, `\interiorof`, `\ball{r}{x}`, `\clball{r}{x}`, `\id[X]`,
`\pvec{x \\ y}`, `\inv`, `\adj`, `\pinv`, `\orthcomp`, `\indep`.

Calculus:

- `\diff[n]{x}`, `\pdiff[n]{x}`.
- `\deriv*[n]{x}{f}`, `\derivat*[n]{x}{f}{a}`, `\dderiv{x}{f}`,
  `\dderivat{x}{f}[y]{a}`.
- `\pderiv*[n]{x}{f}`, `\pderivat*[n]{x}{f}[y]{a}`, `\mpderiv*[n]{d}{f}`,
  `\mpderivat*[n]{d}{f}{x}{a}`, `\mipderiv*{alpha}[x]{f}[a]`.
- `\jacobian[x]{f}[a]`, `\gradient[x]{f}[a]`, `\hessian[x]{f}[a]`, and
  `\laplaceop[x]{f}[a]`: the optional variable is the subscript of the
  operator, and the optional point is where the result is evaluated.
  `\divergence{v}[x]`.
- `\rintegral[a][b]{x}{f}`.

Text: `\onedot`, `\eg`, `\Eg`, `\ie`, `\Ie`, `\cf`, `\Cf`, `\etc`, `\vs`,
`\wrt`, `\dof`, `\etal`, `\iid`, `\eos`.

Theorem environments: `theorem`, `proposition`, `lemma`, `corollary`,
`definition`, `assumption`, `problem`, `remark`.

## Tests

From the repository root:

```sh
l3build check
```

The tests need a checkout of `figmint` next to this repository, which provides
the shared test harness and the package that one test loads, the classes
`beamer`, `jmlr`, `acmart`, and `llncs`, and `pdftotext`.

## License

Apache 2.0.
