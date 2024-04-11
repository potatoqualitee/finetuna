function Invoke-TuneEmbeddingClustering {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Embeddings,
        [int]$NumClusters = 5
    )

    $rows = [int]$Embeddings.Values.Count
    $columns = [int]$Embeddings.Values[0].Length

    # Use the fully qualified name of the DenseMatrix and call the constructor directly.
    $matrix = [MathNet.Numerics.LinearAlgebra.Double.DenseMatrix]::new([int]$rows, [int]$columns)

    $i = 0
    foreach ($embedding in $Embeddings.Values) {
        if ($embedding -is [Array]) {
            $vector = [MathNet.Numerics.LinearAlgebra.Vector[Double]]::Build.Dense($embedding)
            $matrix.SetRow($i, $vector)
            $i++
        } else {
            Write-Error "Expected an array of doubles for each embedding."
            break
        }
    }


    # Initialize KMeans with the desired number of clusters
    $kmeans = New-Object MathNet.Numerics.Statistics.KMeans($NumClusters)

    # Fit the model
    $result = $kmeans.Learn($matrix)

    # Assign clusters
    $clusters = $result.Clusters

    # Output clusters and their members
    for ($i = 0; $i -lt $NumClusters; $i++) {
        Write-Host "Cluster $i : "
        $clusterIndices = $clusters | Where-Object { $_ -eq $i }
        foreach ($index in $clusterIndices) {
            $key = $Embeddings.Keys[$index]
            Write-Host $key
        }
    }
}