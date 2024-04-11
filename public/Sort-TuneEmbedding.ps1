function Sort-TuneEmbedding {
    <#
    .SYNOPSIS
    Classifies text strings by their most similar label using embeddings.

    .DESCRIPTION
    The Sort-TuneEmbedding cmdlet compares embeddings of text strings with label embeddings and assigns each text a label based on the highest similarity.

    .PARAMETER Texts
    The text strings to classify.

    .PARAMETER Labels
    The set of labels to classify the text strings into.

    .EXAMPLE
    $texts = @("Neural networks optimize", "Impressionist art movement", "Symphonies by Beethoven")
    $labels = @("Technology", "Art", "Music")
    Sort-TuneEmbedding -Texts $texts -Labels $labels
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Texts,
        [Parameter(Mandatory)]
        [string[]]$Labels
    )
    process {
        # Compute embeddings for labels first to optimize performance
        $labelEmbeddings = $Labels | ForEach-Object { New-TuneEmbedding -Text $_ }

        $classifications = @()
        foreach ($text in $Texts) {
            $textEmbedding = New-TuneEmbedding -Text $text
            $scores = @()
            for ($i = 0; $i -lt $labelEmbeddings.Length; $i++) {
                $score = [MathNet.Numerics.Distance.Cosine]::Similarity($textEmbedding, $labelEmbeddings[$i])
                $scores += [PSCustomObject]@{
                    Label      = $Labels[$i]
                    Similarity = $score
                }
            }
            # Sort by similarity and select the most similar label
            $bestMatch = $scores | Sort-Object -Property Similarity -Descending | Select-Object -First 1
            $classifications += [PSCustomObject]@{
                Text       = $text
                Label      = $bestMatch.Label
                Similarity = $bestMatch.Similarity
            }
        }

        return $classifications
    }
}