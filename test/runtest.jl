using Test, BibtexDOI

# single-word titles aren't abbreviated
@test BibtexDOI.journal_abbreviation("Science") == "Science"

# do not unconditionally remove capital 'A' even though it is an article
@test BibtexDOI.journal_abbreviation("Physical Review A") == "Phys. Rev. A"
@test BibtexDOI.journal_abbreviation("Physical Review E") == "Phys. Rev. E"

# respect intentionally lowercased journal features
@test BibtexDOI.journal_abbreviation("npj Quantum Materials") == "npj Quantum Mater."

# preserve acronyms abbreviation
@test BibtexDOI.journal_abbreviation("SIAM Reviews") == "SIAM Rev."
@test BibtexDOI.journal_abbreviation("IEEE Photonics Technology Letters") == "IEEE Photonics Technol. Lett."

# abbreviation includes hyphens as word-splitters:
@test BibtexDOI.journal_abbreviation("Non-Crystalline") == "Non-Cryst."


