function Search-TuneEmbedding {
<#
    .SYNOPSIS
    Calculates the cosine similarity between two embedding vectors.

    .DESCRIPTION
    The Search-TuneEmbedding cmdlet takes a query embedding vector and searches for the most similar text embeddings within a collection.
    It returns the top N most similar results based on cosine similarity.

    .PARAMETER QueryEmbedding
    The query embedding vector to search with.

    .PARAMETER Embeddings
    The collection of text embeddings to search through.

    .PARAMETER Top
    Optional. The number of top similar results to return. Default is 5.

    .EXAMPLE
    $queryEmbedding = New-TuneEmbedding -Query "brown fox"
    $embeddings = "The quick brown fox", "A lazy dog", "A cunning fox" | New-TuneEmbedding
    Search-TuneEmbedding -QueryEmbedding $queryEmbedding -Embeddings $embeddings

    This command searches for the most similar text embeddings to the query "brown fox".

    .EXAMPLE
    $queryEmbedding = New-TuneEmbedding -Query "playful dog"
    $embeddings = Get-Content "descriptions.txt" | New-TuneEmbedding
    Search-TuneEmbedding -QueryEmbedding $queryEmbedding -Embeddings $embeddings -Top 3

    This command searches through a collection of embeddings created from a text file and returns the top 3 most similar results to the query.
    #>
    param(
        [Parameter(Mandatory, Position = 0)]
        [double[]]$QueryEmbedding,

        [Parameter(Mandatory, Position = 1)]
        [double[][]]$Embeddings,

        [Parameter()]
        [int]$Top = 5
    )

    $similarities = @()
    foreach ($embedding in $Embeddings) {
        $similarity = Get-TuneEmbeddingSimilarity -Embedding1 $QueryEmbedding -Embedding2 $embedding
        $similarities += @{
            Embedding  = $embedding
            Similarity = $similarity
        }
    }

    $similarities | Sort-Object -Property Similarity -Descending | Select-Object -First $Top
}