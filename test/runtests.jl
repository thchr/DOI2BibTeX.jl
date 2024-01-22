using Test, DOI2BibTeX

## --------------------------------------------------------------------------------------- #
# A few manual tests of journal abbreviations

# single-word titles aren't abbreviated
@test journal_abbreviation("Science") == "Science"

# do not unconditionally remove capital 'A' even though it is an article
@test journal_abbreviation("Physical Review A") == "Phys. Rev. A"
@test journal_abbreviation("Physical Review E") == "Phys. Rev. E"

# respect intentionally lowercased journal features
@test journal_abbreviation("npj Quantum Materials") == "npj Quantum Mater."

# preserve acronyms abbreviation
@test journal_abbreviation("SIAM Reviews") == "SIAM Rev."
@test journal_abbreviation("IEEE Photonics Technology Letters") == "IEEE Photonics Technol. Lett."

# abbreviation includes hyphens as word-splitters:
@test journal_abbreviation("Non-Crystalline") == "Non-Cryst."

# abbreviations with words that abbreviate to themselves ("Light" below)
@test journal_abbreviation("Light: Science & Applications") == "Light: Sci. Appl."

# abbreviations with weirdly formatted ampersands
@test journal_abbreviation(raw"Laser {\&}amp$\mathsemicolon$ Photonics Reviews") == "Laser Photonics Rev."

## abbreviations that include all-capitals followed by ':'
@test journal_abbreviation("Journal of Physics A: Mathematical and Theoretical") == "J. Phys. A: Math. Theor."

## --------------------------------------------------------------------------------------- #
# Test that what we say in the README.md is true:
s_readme = """
@article{klitzing1980new,
  title = {New Method for High-Accuracy Determination of the Fine-Structure Constant Based on Quantized Hall Resistance},
  volume = {45},
  doi = {10.1103/physrevlett.45.494},
  number = {6},
  journal = {Phys. Rev. Lett.},
  author = {Klitzing, K. v. and Dorda, G. and Pepper, M.},
  year = {1980},
  pages = {494–497}
}"""
@test doi2bib("10.1103/PhysRevLett.45.494").s  == s_readme

## --------------------------------------------------------------------------------------- #
## check that we can parse a long list of DOIs

# bugs lists
broken_idxs = [310, 376, 385, 410] # ampersands and backslashes
look_at_idxs = [280] # awkward journal titles that contain descriptions

dois = replace.(split(read(joinpath((@__DIR__), "doi-list.txt"), String), '\n'), '\r' => "")
@testset "Parse list of DOIs" begin
    for (i,doi) in enumerate(dois)
        @test !isempty(doi2bib(doi))
    end
    # FIXME: `i=280`, aka awkward journal titles that contain descriptions (issue #3)
end