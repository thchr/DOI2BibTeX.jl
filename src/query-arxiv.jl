
# ArXiv API https://info.arxiv.org/help/api/basics.html
function _arxiv2bib(arxiv::AbstractString)
	arxiv = _replace(arxiv,
		"arxiv:" => "", "http://" => "", "https://" => "", "arxiv.org/" => "", "abs/" => "")
	return String(HTTP.get("https://arxiv.org/bibtex/$arxiv",
		["Accept" => "application/x-bibtex"]).body)::String
end

function arxiv2bib(arxiv::AbstractString;
	minimal::Bool    = true,
	abbreviate::Bool = true,
)
	arxiv_bib = _arxiv2bib(arxiv)
	# _prettify_bib doesn't completly catch arXiv bibtex frmt
	arxiv_bib = replace(arxiv_bib, r"(?<! )=(?! )" => " = ")
	return _prettify_bib(arxiv_bib, minimal, abbreviate)
end
