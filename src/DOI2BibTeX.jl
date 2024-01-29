module DOI2BibTeX

export doi2bib, arxiv2bib, journal_abbreviation

include("abbreviate.jl")
include("query-doi.jl")
include("query-arxiv.jl")
include("precompile.jl")

end