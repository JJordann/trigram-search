# trigram-search
Approximate string searching algorithm


# Demo

```julia
document = "Lorem ipsum is simply dummy text of the printing and 
            typesetting industry. Lorem ipsum has been the industry 
            standard dummy text ever since the 1500s, when an unknown 
            printer took a galley of type and scrambled it to make 
            a type specimen book."

word = "galley type"

index = makeIndex(document)
searchResults(index, word) |> showResults
```
Output: 
```
(similarity: 8) "galley of type and"
(similarity: 3) "typesetting industry."
(similarity: 2) "a type specimen book"
(similarity: 1) "dummy text of the printing"
(similarity: 1) "dummy text ever since"
```

# Explanation of the method
