function Compare-Embedding {
    <#
    .SYNOPSIS
    Calculates the similarity between two embedding vectors.

    .DESCRIPTION
    The Compare-Embedding command takes a query embedding vector and searches for the most similar text embeddings within a collection.
    It returns the top N most similar results based on the chosen similarity measure.

    .PARAMETER Query
    Some text to be converted to an embedding.

    .PARAMETER QueryEmbedding
    The query embedding vector to search with.

    .PARAMETER Embeddings
    The collection of text embeddings to search through.

    .PARAMETER Top
    Optional. The number of top similar results to return. Default is 25.

    .PARAMETER Type
    The type of similarity measure to use. Options are 'Cosine', 'Euclidean', 'Pearson', 'SquaredEuclidean'. Default is 'Cosine'.

    .EXAMPLE
    $queryEmbedding = Get-Embedding -Query "brown fox"
    $embeddings = @{
        "The quick brown fox" = (Get-Embedding "The quick brown fox");
        "A lazy dog" = (Get-Embedding "A lazy dog");
        "A cunning fox" = (Get-Embedding "A cunning fox")
    }
    Compare-Embedding -QueryEmbedding $queryEmbedding -Embeddings $embeddings

    This command searches for the most similar text embeddings to the query "brown fox".

    .EXAMPLE
    $queryEmbedding = Get-Embedding -Query "playful dog"
    $embeddings = Get-Content "descriptions.txt" | ForEach-Object { @{$_ = Get-Embedding $_} }
    Compare-Embedding -QueryEmbedding $queryEmbedding -Embeddings $embeddings -Top 3

    This command searches through a collection of embeddings created from a text file and returns the top 3 most similar results to the query.
    #>
    [CmdletBinding()]
    param(
        [string]$Query,
        [double[]]$QueryEmbedding,
        [Parameter(Mandatory)]
        [hashtable]$Embeddings,
        [int]$Top = 25,
        [ValidateSet('Cosine', 'Euclidean', 'Pearson', 'SquaredEuclidean')]
        [string]$Type = 'Cosine'
    )
    process {
        if (-not $Query -and -not $QueryEmbedding) {
            throw "You must specify either Query or QueryEmbedding"
        }

        if ($Query) {
            $QueryEmbedding = Get-Embedding -Text $Query
        }

        $similarities = New-Object System.Collections.ArrayList

        foreach ($key in $Embeddings.Keys) {
            $embeddingVector = $Embeddings[$key]
            $similarity = 0

            switch ($Type) {
                'Cosine' {
                    $dotProduct = 0
                    $normQuery = 0
                    $normEmbedding = 0
                    for ($i = 0; $i -lt $QueryEmbedding.Length; $i++) {
                        $dotProduct += $QueryEmbedding[$i] * $embeddingVector[$i]
                        $normQuery += $QueryEmbedding[$i] * $QueryEmbedding[$i]
                        $normEmbedding += $embeddingVector[$i] * $embeddingVector[$i]
                    }
                    $normQuery = [Math]::Sqrt($normQuery)
                    $normEmbedding = [Math]::Sqrt($normEmbedding)
                    if ($normQuery -ne 0 -and $normEmbedding -ne 0) {
                        $similarity = $dotProduct / ($normQuery * $normEmbedding)
                    }
                }
                'Euclidean' {
                    $distance = 0
                    for ($i = 0; $i -lt $QueryEmbedding.Length; $i++) {
                        $diff = $QueryEmbedding[$i] - $embeddingVector[$i]
                        $distance += $diff * $diff
                    }
                    $distance = [Math]::Sqrt($distance)
                    $similarity = 1 / (1 + $distance)
                }
                'Pearson' {
                    $meanQuery = ($QueryEmbedding | Measure-Object -Average).Average
                    $meanEmbedding = ($embeddingVector | Measure-Object -Average).Average
                    $covariance = 0
                    $varQuery = 0
                    $varEmbedding = 0
                    for ($i = 0; $i -lt $QueryEmbedding.Length; $i++) {
                        $diffQuery = $QueryEmbedding[$i] - $meanQuery
                        $diffEmbedding = $embeddingVector[$i] - $meanEmbedding
                        $covariance += $diffQuery * $diffEmbedding
                        $varQuery += $diffQuery * $diffQuery
                        $varEmbedding += $diffEmbedding * $diffEmbedding
                    }
                    if ($varQuery -ne 0 -and $varEmbedding -ne 0) {
                        $correlation = $covariance / ([Math]::Sqrt($varQuery) * [Math]::Sqrt($varEmbedding))
                        $similarity = ($correlation + 1) / 2
                    }
                }
                'SquaredEuclidean' {
                    $distanceSquared = 0
                    for ($i = 0; $i -lt $QueryEmbedding.Length; $i++) {
                        $diff = $QueryEmbedding[$i] - $embeddingVector[$i]
                        $distanceSquared += $diff * $diff
                    }
                    $similarity = 1 / (1 + $distanceSquared)
                }
            }
            $null = $similarities.Add([PSCustomObject]@{ Command = $key; Similarity = $similarity })
        }

        $similarities | Sort-Object -Property Similarity -Descending | Select-Object -First $Top
    }
}