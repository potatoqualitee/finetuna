function Find-TuneAnomaly {
    <#
    .SYNOPSIS
    Detects anomalies in a set of embeddings by identifying embeddings with little relatedness.

    .DESCRIPTION
    The Find-TuneAnomaly cmdlet measures the average similarity of each embedding against all others and identifies those that are far less similar than the majority, suggesting potential anomalies.

    .PARAMETER Embeddings
    The embeddings to analyze for potential anomalies.

    .PARAMETER Threshold
    The threshold below which an embedding is considered an anomaly. This should be a value between 0 and 1.

    .EXAMPLE
    $texts = @("Deep Learning", "Art History", "Convolutional Networks", "Anomaly in data", "Neural Networks")
    $embeddings = $texts | ForEach-Object { New-TuneEmbedding -Text $_ }
    Find-TuneAnomaly -Embeddings $embeddings -Threshold 0.1
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [double[][]]$Embeddings,
        [double]$Threshold = 0.1
    )
    process {
        $anomalies = @()
        $numEmbeddings = $Embeddings.Length

        # Compare each embedding to every other embedding
        for ($i = 0; $i -lt $numEmbeddings; $i++) {
            $currentEmbedding = $Embeddings[$i]
            $totalSimilarity = 0

            foreach ($embedding in $Embeddings) {
                $similarity = [MathNet.Numerics.Distance.Cosine]::Similarity($currentEmbedding, $embedding)
                $totalSimilarity += $similarity
            }

            $averageSimilarity = $totalSimilarity / $numEmbeddings

            # Check if the average similarity is below the threshold
            if ($averageSimilarity -lt $Threshold) {
                $anomalies += $i
            }
        }

        # Return the indices of the anomalies
        return $anomalies
    }
}