function Measure-TuneDiversity {
    <#
    .SYNOPSIS
    Measures the diversity within a set of embeddings by analyzing the distribution of similarities.

    .DESCRIPTION
    The Measure-TuneDiversity cmdlet calculates the average pairwise cosine similarity among all embeddings. A lower average indicates higher diversity, whereas a higher average suggests lower diversity.

    .PARAMETER Embeddings
    The embeddings whose diversity is to be measured.

    .EXAMPLE
    $texts = @("Artificial Intelligence", "Machine Learning", "Deep Learning", "Space Exploration", "Modern Art")
    $embeddings = $texts | ForEach-Object { New-TuneEmbedding -Text $_ }
    Measure-TuneDiversity -Embeddings $embeddings
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [double[][]]$Embeddings
    )
    process {
        $numEmbeddings = $Embeddings.Length
        $totalSimilarity = 0
        $comparisons = 0

        for ($i = 0; $i -lt $numEmbeddings; $i++) {
            for ($j = $i + 1; $j -lt $numEmbeddings; $j++) {
                $similarity = [MathNet.Numerics.Distance.Cosine]::Similarity($Embeddings[$i], $Embeddings[$j])
                $totalSimilarity += $similarity
                $comparisons++
            }
        }

        $averageSimilarity = $totalSimilarity / $comparisons

        # Return the average similarity as the diversity measure
        return $averageSimilarity
    }
}