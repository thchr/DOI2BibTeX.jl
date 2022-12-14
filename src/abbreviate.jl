using TOML

const DATA_PATH = joinpath(@__DIR__, "..", "data")
const LTWA_STARTSWITH = convert(Dict{String, String}, TOML.tryparsefile(joinpath(DATA_PATH, "ltwa_startswith.toml")))::Dict{String, String}
const LTWA_ENDSWITH   = convert(Dict{String, String}, TOML.tryparsefile(joinpath(DATA_PATH, "ltwa_endswith.toml"))  )::Dict{String, String}
const LTWA_CONTAINS   = convert(Dict{String, String}, TOML.tryparsefile(joinpath(DATA_PATH, "ltwa_contains.toml"))  )::Dict{String, String}
const LTWA_ENTIREWORD = convert(Dict{String, String}, TOML.tryparsefile(joinpath(DATA_PATH, "ltwa_entireword.toml")))::Dict{String, String}
const PREPOSITIONS_CONJUNCTIONS_ARTICLES = Set([
  # prepositions: from https://github.com/bahamas10/prepositions
  "abaft", "aboard", "about", "above", "absent", "across", "afore", "after", "against",
  "along", "alongside", "amid", "amidst", "among", "amongst", "anenst", "apropos", "apud",
  "around", "as", "aside", "astride", "at", "athwart", "atop", "barring", "before",
  "behind", "below", "beneath", "beside", "besides", "between", "beyond", "but", "by",
  "circa", "concerning", "despite", "down", "during", "except", "excluding", "failing",
  "following", "for", "forenenst", "from", "given", "in", "including", "inside", "into",
  "lest", "like", "mid", "midst", "minus", "modulo", "near", "next", "notwithstanding",
  "of", "off", "on", "onto", "opposite", "out", "outside", "over", "pace", "past", "per",
  "plus", "pro", "qua", "regarding", "round", "sans", "save", "since", "than", "through",
  "throughout", "till", "times", "to", "toward", "towards", "under", "underneath", "unlike",
  "until", "unto", "up", "upon", "versus", "via", "vice", "with", "within", "without",
  "worth",
  # conjunctions: from https://github.com/verachell/English-word-lists-parts-of-speech-approximate/blob/main/other-categories/mostly-conjunctions.txt
  "after", "albeit", "although", "and", "as", "because", "before", "both", "but",
  "considering", "directly", "either", "ergo", "excepting", "except", "for", "hence",
  "however", "howsoever", "if", "immediately", "inasmuch as", "lest", "like", "moreover",
  "neither", "nevertheless", "nonetheless", "nor", "notwithstanding", "now", "once",
  "otherwise", "provided", "providing", "save", "saving", "seeing", "since", "so",
  "therefore", "though", "unless", "until", "whenever", "when", "whereas", "wheresoever",
  "whereupon", "wherever", "where", "whether", "while", "whilst", "why", "without", "yet",
  # articles: from https://en.wikipedia.org/wiki/English_articles
  "an", "a", "the",
  # TODO: German additions
  "für", "der", "das", "dem", "und",
  "f�r", # bugs from poor unicode handling by DOI response
  # TODO: French additions
  "les", "la", "et", "pre", "avante", "de",
  # TODO: Italian additions,
  "il",
  # TODO: Spanish additions
  ])

function journal_abbreviation(name::AbstractString)
    idx = 1
    io = IOBuffer()
    while idx != 0
        next_idx = findnext(c-> c == ' ' || c == '-', name, idx)
        if next_idx !== nothing
            word = name[idx:prevind(name, next_idx)]
            idx = nextind(name, next_idx)
        else
            if idx == 1 # single-word title: do not abbreviate
                print(io, rstrip(lstrip(name, '{'), '}'))
                break
            else
                word = name[idx:end]
                idx = 0
            end
        end
        
        abbr = abbreviate(word)
        if !isempty(abbr) # empty if we removed an article/preposition/conjunction
            print(io, abbr)
            idx == 0 || print(io, name[something(next_idx)]) # print ' ' or '-'
        end
    end
    abbr_name = String(take!(io))
    return abbr_name
end

function abbreviate(word::AbstractString)
    word′ = rstrip(lstrip(word, '{'), '}')
    if all(isuppercase, word′)
        # interpret as acronym/volume number (e.g., 'IEEE' or 'A'); no further abbreviation
        return word′
    else
        abbrev = abbreviate_lowercased(rstrip(lowercase(word′), ':'))
        return restore_capitalization_and_colon(abbrev, word′)
    end
end

function abbreviate_lowercased(word::AbstractString)
    # roughly, we try to follow the ISO-4 rules, as e.g. summarized here
    # https://marcinwrochna.github.io/abbrevIso/
    # NB: the implementation assumes that `word` has been lowercased
    
    if haskey(LTWA_ENTIREWORD, word)
        # replace entire word by direct abbreviation
        return LTWA_ENTIREWORD[word]
    end

    if last(word) == 's'
        # same as above, but check for matches with English plural '-s' forms
        singular_word = word[1:prevind(word, ncodeunits(word))]
        if haskey(LTWA_ENTIREWORD, singular_word)
            return LTWA_ENTIREWORD[singular_word]
        end
    end

    # remove any prepositions/articles/conjunctions and also any "Part"/"Section"/"Series"
    if word ∈ PREPOSITIONS_CONJUNCTIONS_ARTICLES || word ∈ ("part", "section", "series")
        return ""
    end

    # since there are ~20.000 words in `LTWA_STARTSWITH`, it is much better (especially in
    # the case where there is no match) to iterate over all "starting substrings" of `word`
    # and check against `haskey` (as opposed to e.g. checking all keys of `LTWA_STARTSWITH`
    # against `startswith(word)`)
    # [the same does not apply to `LTWA_ENDSWITH` or  `LTWA_CONTAINS` since they contains
    # very few entries (167 and 20, respectively), s.t. iteration is at least okay there]
    i = 0
    while (i = nextind(word, i)) ≤ ncodeunits(word)
        sub_word = @view word[1:i]
        if haskey(LTWA_STARTSWITH, sub_word)
            # discard ending, abbreviate beginning
            return LTWA_STARTSWITH[sub_word]
        end
    end

    for word_end in keys(LTWA_ENDSWITH)
        if endswith(word, word_end)
            # keep beginning, abbreviate ending
            idx = prevind(word, first(something(findlast(word_end, word))))
            return word[1:idx] * LTWA_ENDSWITH[word_end]
        end
    end

    for word_contains in keys(LTWA_CONTAINS)
        if contains(word, word_contains)
            # keep beginning, abbreviate middle, discard ending
            idx = prevind(word, first(something(findlast(word_contains, word))))
            return word[1:idx] * LTWA_CONTAINS[word_contains]
        end
    end

    # no abbreviations found: keep original word
    return word
end

function restore_capitalization_and_colon(abbrev::AbstractString, word::AbstractString)
    ncodeunits(abbrev) ≤ ncodeunits(word) || error("abbreviation is longer than word")

    # restore capitalization in `abbrev`, mirroring that in `word`, from start of `word`
    io = IOBuffer()
    for (c, c′) in zip(abbrev, word)
        if isuppercase(c′)
            write(io, uppercase(c))
        else
            write(io, c)
        end
    end
    # restore possibly deleted colons
    endswith(word, ':') && !endswith(abbrev, ':') && write(io, ':')

    return String(take!(io))
end