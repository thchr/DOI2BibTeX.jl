using HTTP

struct Citation
    # TODO: Replace by `SimpleBibTeX.jl`'s equivalent struct?
    s :: String
end
Base.show(io::IO, ::MIME"text/plain", c::Citation) = print(io, c.s)

# see https://discourse.julialang.org/t/replacing-citation-bib-with-a-standard-metadata-format/26871/4
# and the crossref API at https://citation.crosscite.org/docs.html
function _doi2bib(doi::AbstractString)
    doi = replace(doi, "http://" => "", "https://" => "", "doi.org/"=>"")
    return String(HTTP.get("https://doi.org/$doi",
                           ["Accept" => "application/x-bibtex"]).body)
end

function doi2bib(doi::AbstractString;
            minimal::Bool    = true, # remove unnecessary bibtex fields
            abbreviate::Bool = true  # abbreviate journal title
            )

    s = _doi2bib(doi)

    # TODO: Would be a ton better to do all these things with a dedicated BibTeX parser
    #       (the regex hacks don't really cut it; need a proper automata).
    #       Both Bibliography.jl and BibTeX.jl have awkward interfaces though: maybe just
    #       polish up /thchr/SimpleBibTeX.jl and use that?

    # remove unnecessary fields
    if minimal
        s = replace(s, r"\n\t(publisher|month|url) =.*" => "")
    end

    # change tabs to double-spaces
    s = replace(s, "\t" => "  ")

    # generate a better name for the entry
    firstword = try
        # TODO: quite fragile (e.g., if first word starts with '{')
        lowercase(something(match(r"  title = {(\w+)[\s|-]", s)).captures[1])
    catch
        ""
    end
    doctype, author, year = something(match(r"(@\w+\{)(\w+)_([0-9]+),", s)).captures
    author = lowercase(author)
    s = replace(s, r"@\w+\{\w+_[0-9]+" => doctype*author*year*firstword)

    # abbreviate the journal title
    if abbreviate
        journal_name = something(match(r"journal = \{(.+)\},?\n", s)).captures[1]
        journal_abbr = journal_abbreviation(journal_name)
        s = replace(s, r"journal = \{.+\}(,?\n)" => 
                       SubstitutionString("journal = {"*journal_abbr*"}\\1"))
    end

    return Citation(s)
end