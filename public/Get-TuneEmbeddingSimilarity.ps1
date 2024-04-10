function Get-TuneEmbeddingSimilarity {
    <#
.SYNOPSIS
Calculates the cosine similarity between two embedding vectors.

.DESCRIPTION
The Get-TuneSimilarity cmdlet takes two embedding vectors and calculates their cosine similarity.
The similarity score ranges from 0 to 1, where 1 indicates maximum similarity.

.PARAMETER Embedding1
The first embedding vector.

.PARAMETER Embedding2
The second embedding vector.

.EXAMPLE
$embedding1 = New-TuneEmbedding -Text "The quick brown fox"
$embedding2 = New-TuneEmbedding -Text "A fast brown fox"
Get-TuneSimilarity -Embedding1 $embedding1 -Embedding2 $embedding2

This command calculates the similarity between two embeddings created from slightly different text.

.EXAMPLE
$embeddings = "The quick brown fox", "A fast brown fox" | New-TuneEmbedding
Get-TuneSimilarity -Embedding1 $embeddings[0] -Embedding2 $embeddings[1]

This command calculates similarity on embeddings piped from New-TuneEmbedding.
#>
    param(
        [Parameter(Mandatory, Position = 0)]
        [double[]]$Embedding1,

        [Parameter(Mandatory, Position = 1)]
        [double[]]$Embedding2
    )

    $dotProduct = 0
    for ($i = 0; $i -lt $Embedding1.Count; $i++) {
        $dotProduct += $Embedding1[$i] * $Embedding2[$i]
    }

    $magnitude1 = [math]::Sqrt([math]::Sum([math]::Pow($Embedding1, 2)))
    $magnitude2 = [math]::Sqrt([math]::Sum([math]::Pow($Embedding2, 2)))

    $dotProduct / ($magnitude1 * $magnitude2)
}