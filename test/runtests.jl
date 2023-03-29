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