function Compare-Embedding {
<#
    .SYNOPSIS
    Calculates the cosine similarity between two embedding vectors.

    .DESCRIPTION
    The Compare-Embedding command takes a query embedding vector and searches for the most similar text embeddings within a collection.

    It returns the top N most similar results based on cosine similarity.

    .PARAMETER Query
    Some text

    .PARAMETER QueryEmbedding
    The query embedding vector to search with.

    .PARAMETER Embeddings
    The collection of text embeddings to search through.

    .PARAMETER Top
    Optional. The number of top similar results to return. Default is 5.

    .EXAMPLE
    $queryEmbedding = Get-Embedding -Query "brown fox"
    $embeddings = "The quick brown fox", "A lazy dog", "A cunning fox" | Get-Embedding
    Compare-Embedding -QueryEmbedding $queryEmbedding -Embeddings $embeddings

    This command searches for the most similar text embeddings to the query "brown fox".

    .EXAMPLE
    $queryEmbedding = Get-Embedding -Query "playful dog"
    $embeddings = Get-Content "descriptions.txt" | Get-Embedding
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

        $queryVector = [MathNet.Numerics.LinearAlgebra.Double.DenseVector]::OfArray($QueryEmbedding)
        $similarities = New-Object System.Collections.ArrayList

        foreach ($key in $Embeddings.Keys) {
            $embeddingVector = [MathNet.Numerics.LinearAlgebra.Double.DenseVector]::OfArray($Embeddings[$key])
            $similarity = 0

            switch ($Type) {
                'Cosine' {
                    # Correctly calculate cosine similarity using dot product and norms
                    $dotProduct = $queryVector.DotProduct($embeddingVector)
                    $normsProduct = $queryVector.L2Norm() * $embeddingVector.L2Norm()
                    if ($normsProduct -ne 0) {
                        $similarity = $dotProduct / $normsProduct
                    } else {
                        $similarity = 0
                    }
                }
                'Euclidean' {
                    # Correct Euclidean distance calculation
                    $distanceVector = $queryVector.Subtract($embeddingVector)
                    $distance = $distanceVector.L2Norm()
                    $similarity = 1 / (1 + $distance)
                }
                'Pearson' {
                    $keyEmbedding = [double[]]($Embeddings[$key])
                    # Pearson correlation calculation appears correct
                    $correlation = [MathNet.Numerics.Statistics.Correlation]::Pearson($QueryEmbedding, $keyEmbedding)
                    $similarity = ($correlation + 1) / 2
                }
                'SquaredEuclidean' {
                    # Adjust Squared Euclidean distance calculation
                    $distanceVector = $queryVector.Subtract($embeddingVector)
                    $distance = $distanceVector.L2Norm()
                    $distanceSquared = $distance * $distance
                    $similarity = 1 / (1 + $distanceSquared)
                }
            }
            $null = $similarities.Add([PSCustomObject]@{ Command = $key; Similarity = $similarity })
        }


        $similarities |  Sort-Object -Property Similarity -Descending | Select-Object -First $Top
    }
}