function Get-TuneRecommendation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ReferenceText,
        [Parameter(Mandatory)]
        [double[][]]$Embeddings,
        [Parameter(Mandatory)]
        [string[]]$Items
    )
    process {
        # Compute embedding for the reference text
        $refEmbedding = New-TuneEmbedding -Text $ReferenceText

        # Convert reference embedding to a dense vector
        $refVector = [MathNet.Numerics.LinearAlgebra.Double.DenseVector]::OfArray($refEmbedding)

        # Calculate cosine similarity with all other embeddings
        $scores = New-Object System.Collections.ArrayList

        for ($i = 0; $i -lt $Embeddings.Length; $i++) {
            $embeddingVector = [MathNet.Numerics.LinearAlgebra.Double.DenseVector]::OfArray($Embeddings[$i])

            # Pad the shorter vector with zeros to match the length of the longer vector
            $maxLength = [Math]::Max($refVector.Count, $embeddingVector.Count)
            $refPadded = [MathNet.Numerics.LinearAlgebra.Double.DenseVector]::OfArray($refVector.Concat([double[]]::new($maxLength - $refVector.Count)).ToArray())
            $embeddingPadded = [MathNet.Numerics.LinearAlgebra.Double.DenseVector]::OfArray($embeddingVector.Concat([double[]]::new($maxLength - $embeddingVector.Count)).ToArray())

            $dotProduct = $refPadded.DotProduct($embeddingPadded)
            $normsProduct = $refPadded.L2Norm() * $embeddingPadded.L2Norm()

            if ($normsProduct -ne 0) {
                $similarity = $dotProduct / $normsProduct
            } else {
                $similarity = 0
            }

            write-warning $Items[$i]
            $null = $scores.Add([PSCustomObject]@{
                Item = $Items[$i]
                Similarity = $similarity
            })
        }

        # Sort by similarity in descending order and take the top 'Count' items
        $scores | Sort-Object -Property Similarity -Descending
    }
}