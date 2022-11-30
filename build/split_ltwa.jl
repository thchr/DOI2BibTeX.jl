using DelimitedFiles
cd(@__DIR__)

d = readdlm("../data/ltwa_raw.csv", ';', String)
words = d[:,1]
abbrs = d[:,2]

startswith_idxs = findall(s -> first(s) != '-' && last(s) == '-', words)
endswith_idxs   = findall(s -> first(s) == '-' && last(s) != '-', words)
contains_idxs   = findall(s -> first(s) == '-' && last(s) == '-', words)
entireword_idxs = findall(s -> first(s) != '-' && last(s) != '-', words)

@assert sort!(vcat(startswith_idxs, endswith_idxs, contains_idxs, entireword_idxs)) == eachindex(words)
for (i1, idxs1) in enumerate([startswith_idxs, endswith_idxs, contains_idxs, entireword_idxs])
    for (i2, idxs2) in enumerate([startswith_idxs, endswith_idxs, contains_idxs, entireword_idxs])
        if i1 ≠ i2
            @assert isdisjoint(idxs1, idxs2)
        end
    end
end

startswith_d = Dict(lowercase(rstrip(words[i], '-')) => lowercase(rstrip(abbrs[i], '-')) for i in startswith_idxs)
endswith_d   = Dict(lowercase(lstrip(words[i], '-')) => lowercase(lstrip(abbrs[i], '-')) for i in endswith_idxs)
contains_d   = Dict(lowercase(strip(words[i], '-'))  => lowercase(strip(abbrs[i], '-'))  for i in contains_idxs)
entireword_d = Dict(lowercase(words[i])              => lowercase(abbrs[i])              for i in entireword_idxs)

# remove entries whose abbreviation is "n.a." (i.e., missing/noexistent)
filter!(p->p.second != "n.a.", startswith_d)
filter!(p->p.second != "n.a.", endswith_d)
filter!(p->p.second != "n.a.", contains_d)
filter!(p->p.second != "n.a.", entireword_d)

# ---------------------------------------------------------------------------------------- #
# write to TOML files
using TOML

open("../data/ltwa_startswith.toml", "w") do io
    TOML.print(io, startswith_d)
end
open("../data/ltwa_endswith.toml", "w") do io
    TOML.print(io, endswith_d)
end
open("../data/ltwa_contains.toml", "w") do io
    TOML.print(io, contains_d)
end
open("../data/ltwa_entireword.toml", "w") do io
    TOML.print(io, entireword_d)
end