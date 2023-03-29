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

