using HTTP

struct Citation
    # TODO: Replace by `SimpleBibTeX.jl`'s equivalent struct?
    s :: String
end
Base.show(io::IO, ::MIME"text/plain", c::Citation) = print(io, c.s)
Base.iterate(c::Citation, state=1) = iterate(c.s, state)

# see https://discourse.julialang.org/t/replacing-citation-bib-with-a-standard-metadata-format/26871/4
# and the crossref API at https://citation.crosscite.org/docs.html
function _doi2bib(doi::AbstractString)
    doi = _replace(doi,
                   "http://" => "", "https://" => "", "doi.org/"=>"", "dx.doi.org/"=>"")
    return String(HTTP.get("https://doi.org/$doi",
                           ["Accept" => "application/x-bibtex"]).body)::String
end

function doi2bib(doi::AbstractString;
            minimal::Bool    = true, # remove unnecessary bibtex fields
            abbreviate::Bool = true  # abbreviate journal title
            )

    return _prettify_bib(_doi2bib(doi), minimal, abbreviate)
end

function _prettify_bib(s::String, minimal::Bool, abbreviate::Bool)
    # TODO: Would be a ton better to do all these things with a dedicated BibTeX parser
    #       (the regex hacks don't really cut it; need a proper automata).
    #       Both Bibliography.jl and BibTeX.jl have awkward interfaces though: maybe just
    #       polish up /thchr/SimpleBibTeX.jl and use that?

    # the GET request often includes a redundant leading space; remove it
    if startswith(s, " ")
        s = lstrip(s)
    end

    # insert a double space before every field
    s = replace(s, r"\, ([a-z,A-Z]+?)=" => s",\n  \1 = ")

    # remove unnecessary fields
    if minimal
        s = replace(s, r"\n  (publisher|month|url) =.*" => "")
    end

    # generate a better name for the entry
    firstword = _tryparse_first_word_of_title(s)
    doctype, author, year = _tryparse_doctype_author_year(s)
    s = replace(s, r"@\w+\{.*" => "@"*doctype*"{"*author*year*firstword*","; count=1)

    # abbreviate the journal title
    if abbreviate
        m = match(r"journal=\{(.+)\},?\n", s)
        if !isnothing(m)
            journal_name = something(m).captures[1]
            journal_abbr = journal_abbreviation(journal_name)
            s = replace(s, r"journal = \{.+\}(,?\n)" => 
                            SubstitutionString("journal = {"*journal_abbr*"}\\1"))
        end
    end

    # the GET request has a space-dangling close bracket `" }\n"`: fix it
    if endswith(s, " }\n")
        stopidx = prevind(s, lastindex(s), 3)
        s = s[1:stopidx] * "\n}"
    end

    return Citation(s)
end

function _tryparse_first_word_of_title(s)
    m = match(r"  title = \{(\w+)[\s|-]", s)
    m = match(r"  title = \{[\W|\s]?+(\w+)[\s|-]", s) # FIXME: ignore non-word starting titles
    # regex-approach is fragile (e.g., if 1st word starts with '{'): bail if unsuccesful
    return !isnothing(m) ? lowercase(something(m).captures[1]) : ""
end

function _tryparse_doctype_author_year(s)
    m = match(r"@(\w+)\{(\w+)_([0-9]+),", s)
    if !isnothing(m)
        return m.captures[1], lowercase(m.captures[2]), m.captures[3] # doctype, author, year
    else
        # try to parse individual entries to get desired information
        m₁ = match(r"@(\w+)\{.*,\n", s)
        doctype = !isnothing(m₁) ? m₁.captures[1] : ""
        m₂ = match(r"  (author|editor) = {(.+)},", s)
        author = if !isnothing(m₂)
            firstauthor = split(m₂.captures[2], " and ")[1]
            author = lowercase(split(firstauthor, isspace)[end])
        else
            "johndoe" # unknown author sentinel
        end
        m₃ = match(r"  year = {?([0-9]*)}?", s)
        year = !isnothing(m₃) ? m₃.captures[1] : "0000" # unknown year sentinel
        
        return doctype, author, year
    end
end

@static if VERSION < v"1.7"
    # multi pattern `replace` only introduced in 1.7: add a work-around
    function _replace(str::String, ps::Vararg{Pair, N}) where N
        for p in ps
            str = replace(str, p)
        end
        return str
    end
else
    _replace(str::String, ps::Vararg{Pair, N}) where N = replace(str, ps...)
end