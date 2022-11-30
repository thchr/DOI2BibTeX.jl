using TOML

const LTWA_STARTSWITH = convert(Dict{String, String}, TOML.tryparsefile("data/ltwa_startswith.toml"))::Dict{String, String}
const LTWA_ENDSWITH   = convert(Dict{String, String}, TOML.tryparsefile("data/ltwa_endswith.toml")  )::Dict{String, String}
const LTWA_CONTAINS   = convert(Dict{String, String}, TOML.tryparsefile("data/ltwa_contains.toml")  )::Dict{String, String}
const LTWA_ENTIREWORD = convert(Dict{String, String}, TOML.tryparsefile("data/ltwa_entireword.toml"))::Dict{String, String}
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
  "an", "a", "the"])

function journal_abbreviation(name::AbstractString)
    idx = 1
    io = IOBuffer()
    while idx != 0
        next_idx = findnext(' ', name, idx)
        if next_idx !== nothing
            word = name[idx:prevind(name, next_idx)]
            idx = nextind(name, next_idx)
        else
            word = name[idx:end]
            idx = 0
        end

        abbr = abbreviate(lowercase(word))
        if !isempty(abbr) # empty if we removed an article/preposition/conjunction
            print(io, abbr)
            idx == 0 || print(io, ' ')
        end
    end
    abbr_name = String(take!(io))
    return titlecase(abbr_name)
end

function abbreviate(word::AbstractString)
    # roughly, we try to follow the ISO-4 rules, as e.g. summarized here
    # https://marcinwrochna.github.io/abbrevIso/
    # NB: the implementation assumes that `word` has been lowercased
    
    if haskey(LTWA_ENTIREWORD, word)
        # replace entire word by direct abbreviation
        abbr = LTWA_ENTIREWORD
        return LTWA_ENTIREWORD[word]
    end

    # remove any prepositions/articles/conjunctions and also any "Part"/"Section"/"Series"
    if word ∈ PREPOSITIONS_CONJUNCTIONS_ARTICLES || word ∈ ("part", "section", "series")
        return ""
    end

    # TODO: since there are so many words in `LTWA_STARTSWITH`, it would be much better to
    #       instead iterate over all substrings of `word` and check against `haskey` rather
    #       than using `startswith`
    for word_start in keys(LTWA_STARTSWITH)
        if startswith(word, word_start)
            # discard ending, abbreviate beginning
            return LTWA_STARTSWITH[word_start]
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