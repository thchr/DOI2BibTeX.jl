# DOI2BibTeX.jl

[![Build status][ci-status-img]][ci-status-url] [![Coverage][coverage-img]][coverage-url]

Get a well-formatted, journal-abbreviated BibTeX string from a DOI:

```jl
julia> using DOI2BibTeX
julia> doi = "10.1103/PhysRevLett.45.494"
julia> doi2bib(doi)
```
With output:

> ```
> @article{klitzing1980new,
>   doi = {10.1103/physrevlett.45.494},
>   year = 1980,
>   volume = {45},
>   number = {6},
>   pages = {494--497},
>   author = {K. v. Klitzing and G. Dorda and M. Pepper},
>   title = {New Method for High-Accuracy Determination of the Fine-Structure Constant Based on Quantized Hall Resistance},
>   journal = {Phys. Rev. Lett.}
> }
>```

The BibTeX entry is obtained from a GET request to https://doi.org/, following the approach described [here](https://discourse.julialang.org/t/replacing-citation-bib-with-a-standard-metadata-format/26871/4).

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

The package is not currently registered. Install directly from the repository URL:
```jl
julia> import Pkg
julia> Pkg.add("https://github.com/thchr/DOI2BibTeX.jl")
```

[ci-status-img]: https://github.com/thchr/DOI2BibTeX.jl/actions/workflows/ci.yml/badge.svg?branch=master
[ci-status-url]: https://github.com/thchr/DOI2BibTeX.jl/actions/workflows/ci.yml?query=branch%3Amaster
[coverage-img]:  https://codecov.io/gh/thchr/DOI2BibTeX.jl/branch/master/graph/badge.svg
[coverage-url]:  https://codecov.io/gh/thchr/DOI2BibTeX.jl