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