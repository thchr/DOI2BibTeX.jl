# DOI2BibTeX.jl

[![Build status][ci-status-img]][ci-status-url] [![Coverage][coverage-img]][coverage-url]

Get a well-formatted, journal-abbreviated BibTeX string from a DOI:

```jl
julia> using DOI2BibTeX
julia> doi = "10.1103/PhysRevLett.45.494"
julia> doi2bib(doi)
@article{klitzing1980new,
  title = {New Method for High-Accuracy Determination of the Fine-Structure Constant Based on Quantized Hall Resistance},
  volume = {45},
  doi = {10.1103/physrevlett.45.494},
  number = {6},
  journal = {Phys. Rev. Lett.},
  author = {Klitzing, K. v. and Dorda, G. and Pepper, M.},
  year = {1980},
  pages = {494–497}
}
```

The BibTeX entry is obtained from a GET request to https://doi.org/, following the approach described [here](https://discourse.julialang.org/t/replacing-citation-bib-with-a-standard-metadata-format/26871/4).

### arXiv BibTeX 

It is also possible to obtain an BibTeX entry associated with an [arXiv](https://arxiv.org) identifier:

```jl
julia> using DOI2BibTeX
julia> arxiv = "arxiv:1710.10324"
julia> arxiv2bib(arxiv)
@misc{xie2018crystal,
  title = {Crystal Graph Convolutional Neural Networks for an Accurate and Interpretable Prediction of Material Properties},
  author = {Tian Xie and Jeffrey C. Grossman},
  year = {2018},
  eprint = {1710.10324},
  archivePrefix = {arXiv},
  primaryClass = {cond-mat.mtrl-sci}
}
```

## Journal abbreviations

Journal titles returned by `doi2bib` are automatically abbreviated using the [List of Title Word Abbreviations](https://www.issn.org/services/online-services/access-to-the-ltwa/) (disable by setting the `abbreviate` keyword argument of `doi2bib` to `false`).

The functionality is also separately accessible via the exported function `journal_abbreviation`:

```jl
julia> journal_abbreviation("Physical Review Letters")
"Phys. Rev. Lett."

julia> journal_abbreviation("Journal of Physical Chemistry Letters")
"J. Phys. Chem. Lett."

julia> journal_abbreviation("npj Quantum Materials")
"npj Quantum Mater."
```

## Installation

The package is registered in Julia's General registry and can be installed from the `pkg>` prompt:
```jl
pkg> add DOI2BibTeX
```

[ci-status-img]: https://github.com/thchr/DOI2BibTeX.jl/actions/workflows/ci.yml/badge.svg?branch=master
[ci-status-url]: https://github.com/thchr/DOI2BibTeX.jl/actions/workflows/ci.yml?query=branch%3Amaster
[coverage-img]:  https://codecov.io/gh/thchr/DOI2BibTeX.jl/branch/master/graph/badge.svg
[coverage-url]:  https://codecov.io/gh/thchr/DOI2BibTeX.jl
