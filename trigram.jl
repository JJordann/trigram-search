using Plots

trigramify = doc ->
    [doc[i:i+2] for i in 1:(length(doc)-2)]


findOccurances = (doc, word) -> 
    [i for i in 1:(length(doc)-2)
         if (doc[i:i+2] == word)]


makeIndex = doc ->
    Dict([word => findOccurances(doc, word) 
          for word in trigramify(doc)])


findMatches = (word, index) -> 
    seq([get(index, trigram, []) 
         for trigram in trigramify(word)])


seq = sort ∘ collect ∘ Iterators.flatten


function sequenceLength(matches, position, threshold)
    for i in position:length(matches)
        if matches[i] - matches[position] > threshold
            return i - position
        end
    end

    length(matches) - position
end


rankMatches = (matches, threshold) -> 
    [sequenceLength(matches, i, threshold) 
        for i in 1:length(matches)]


    
# returns disjoint segments of the document containing matches,
# preserving higher ranking matches
function removeOverlapping(matches, ranks, threshold) 
    pruned = [1]
    bestRank = ranks[1]
    for i in 1:length(matches)
        if abs(matches[i] - matches[last(pruned)]) < threshold
            if bestRank < ranks[i]

                # current element is ranked higher than last(pruned)
                # replace last(pruned) with current element
                pruned[end] = i
                bestRank = ranks[i]
                #
                # Otherwise:
                # current element is ranked lower than last(pruned),
                # discard current element
            end
        else
            append!(pruned, i)
            bestRank = ranks[i]
        end
    end

    pruned
end


function extractWords(doc, first, last) 

    if last > length(doc)
        last = length(doc)
    end

    while first > 1 && doc[first - 1] != ' ' 
        first -= 1
    end

    while last < length(doc) - 1 && doc[last + 1] != ' '
        last += 1
    end

    doc[first:last] |> (lstrip ∘ rstrip)
end


function searchResults(index, word)
    threshold = round(Int, length(word) * 1.5)

    matches = findMatches(word, index) 
    ranks = rankMatches(matches, threshold)

    indices = removeOverlapping(matches, ranks, threshold)

    pruned = [matches[i] for i in indices]
    ranks  = [ranks[i] for i in indices]

    ps = sortperm(ranks, rev = true)
    pruned = pruned[ps]

    results = [extractWords(document, pos, pos + threshold)
                   for pos in pruned]

    hcat(results, ranks[ps])
end


function showResults(results) 
    for res in eachrow(results)
        score = res[2]
        str = res[1]
        println("(similarity: $score) \"$str\"")
    end
end


# ---- test ---- #

document = "Lorem ipsum is simply dummy text of the printing and 
            typesetting industry. Lorem ipsum has been the industry 
            standard dummy text ever since the 1500s, when an unknown 
            printer took a galley of type and scrambled it to make 
            a type specimen book."

word = "galley type"

index = makeIndex(document)
results = searchResults(index, word)

showResults(results)




