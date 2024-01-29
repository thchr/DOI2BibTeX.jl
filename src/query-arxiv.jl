
# ArXiv API https://info.arxiv.org/help/api/basics.html
function _arxiv2bib(arxiv::AbstractString)
	arxiv = _replace(arxiv,
		"arxiv:" => "", "http://" => "", "https://" => "", "arxiv.org/" => "", "arxiv.org/abs" => "")
	return String(HTTP.get("https://arxiv.org/bibtex/$arxiv",
		["Accept" => "application/x-bibtex"]).body)::String
end

function arxiv2bib(arxiv::AbstractString;
	minimal::Bool    = true,
	abbreviate::Bool = true,
)
	arxiv_bib = _prettify_arxiv(_arxiv2bib(arxiv))
	return _prettify_bib(arxiv_bib, minimal, abbreviate)
end

# _prettify_bib doesn't completely process arXiv bibtex
function _prettify_arxiv(bibtex::AbstractString)
    # Spacing
    bibtex = replace(bibtex, r"(?<! )=(?! )" => " = ")

	# Regular expression to match the author field
	author_regex = r"author={([^}]+)}"
	match_data = match(author_regex, bibtex)

	# Check if the author field was found
	if isnothing(match_data)
		return bibtex
	end

	# Extract the authors and split them
	authors_raw = match_data.captures[1]
	authors = split(authors_raw, " and ")
	transformed_authors = [_reformat_single_author(author) for author in authors]
	authors_formatted = join(transformed_authors, " and ")
	return replace(bibtex, author_regex => "author={$authors_formatted}")
end

function _reformat_single_author(author::AbstractString)
	parts = split(author, " ")
	last_name = parts[end]
	first_names = join(parts[1:end-1], " ")
	return "$(last_name), $(first_names)"
end




