function Group-TuneEmbedding {
    <#
.SYNOPSIS
Clusters embeddings into groups based on similarity.

.DESCRIPTION
The Group-TuneEmbedding cmdlet uses k-means clustering to group embeddings into a specified number of clusters.
It can accept embeddings as an array of arrays or as a hashtable where the keys are the item identifiers and the values are the embedding arrays.

.PARAMETER Embeddings
Array of embeddings to be clustered.

.PARAMETER EmbeddingHash
Hashtable of embeddings to be clustered, where the keys are item identifiers and the values are embedding arrays.

.PARAMETER ClusterCount
Number of clusters.

.EXAMPLE
$embeddings = @(
    (0..511 | ForEach-Object { Get-Random -Minimum 0 -Maximum 1.0 }),
    (0..511 | ForEach-Object { Get-Random -Minimum 0 -Maximum 1.0 }),
    (0..511 | ForEach-Object { Get-Random -Minimum 0 -Maximum 1.0 })
)
Group-TuneEmbedding -Embeddings $embeddings -ClusterCount 3

.EXAMPLE
$embeddingHash = @{
    "Item1" = (0..511 | ForEach-Object { Get-Random -Minimum 0 -Maximum 1.0 })
    "Item2" = (0..511 | ForEach-Object { Get-Random -Minimum 0 -Maximum 1.0 })
    "Item3" = (0..511 | ForEach-Object { Get-Random -Minimum 0 -Maximum 1.0 })
}
Group-TuneEmbedding -EmbeddingHash $embeddingHash -ClusterCount 3
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = "Embeddings")]
        [double[][]]$Embeddings,

        [Parameter(Mandatory, ParameterSetName = "EmbeddingHash")]
        [hashtable]$EmbeddingHash,

        [Parameter(Mandatory)]
        [int]$ClusterCount
    )
    process {
        $cSharpCode = @"
using System;
using System.Collections.Generic;
using Microsoft.ML;
using Microsoft.ML.Data;

public class TextData {
    public string Text { get; set; }
}

public class ClusterPrediction {
    [VectorType(2)]
    public float[] Features { get; set; }
    [ColumnName("PredictedLabel")]
    public uint PredictedClusterId { get; set; }
}

public class ClusteringHelper {
    private MLContext mlContext;
    private IDataView dataView;
    private PredictionEngine<TextData, ClusterPrediction> predEngine;

    public ClusteringHelper() {
        mlContext = new MLContext();
    }

    public void LoadData(List<string> texts) {
        var samples = new List<TextData>();
        texts.ForEach(text => samples.Add(new TextData { Text = text }));
        dataView = mlContext.Data.LoadFromEnumerable(samples);
    }

    public void CreateModel() {
        var pipeline = mlContext.Transforms.Text.FeaturizeText("Features", nameof(TextData.Text))
            .Append(mlContext.Clustering.Trainers.KMeans("Features", numberOfClusters: 3));

        var model = pipeline.Fit(dataView);
        predEngine = mlContext.Model.CreatePredictionEngine<TextData, ClusterPrediction>(model);
    }

    public uint Predict(string text) {
        var prediction = predEngine.Predict(new TextData { Text = text });
        return prediction.PredictedClusterId;
    }
}
"@

        Add-Type -TypeDefinition $cSharpCode -ReferencedAssemblies @("MathNet.Numerics", "Microsoft.ML.Core", "Microsoft.ML.CpuMath", "Microsoft.ML.Data", "Microsoft.ML.DataView", "Microsoft.ML", "Microsoft.ML.KMeansClustering", "Microsoft.ML.PCA", "Microsoft.ML.StandardTrainers", "Microsoft.ML.Transforms", "SharpToken", "System.Collections.Immutable", "System.Memory")

        # Output the cluster for each embedding as a [pscustomobject]
        if ($PSCmdlet.ParameterSetName -eq "Embeddings") {
            $index = 0
            foreach ($prediction in $predictedLabels) {
                [pscustomobject]@{
                    EmbeddingIndex = $index
                    Cluster        = $prediction.PredictedLabel
                }
                $index++
            }
        } else {
            foreach ($key in $EmbeddingHash.Keys) {
                [pscustomobject]@{
                    ItemId  = $key
                    Cluster = $predictedLabels[$index].PredictedLabel
                }
                $index++
            }
        }
    }
}