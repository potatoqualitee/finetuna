function New-TuneEmbedding {
<#
    .SYNOPSIS
    Creates an embedding vector for the given text using the OpenAI API.

    .DESCRIPTION
    The New-TuneEmbedding cmdlet sends text to the OpenAI API to create an embedding vector.
    Embedding vectors can be used to measure semantic similarity between pieces of text.

    .PARAMETER Text
    The text to create an embedding for.

    .PARAMETER Query
    Optional. A text search query to create an embedding for. Use this when you want to search for similar text rather than compare text similarity.

    .PARAMETER Model
    Optional. The name of the embedding model to use. Default is "text-embedding-ada-002".

    .EXAMPLE
    New-TuneEmbedding -Text "The quick brown fox jumps over the lazy dog"

    This command creates an embedding vector for the given text.

    .EXAMPLE
    "The quick brown fox" | New-TuneEmbedding

    This command pipes text to New-TuneEmbedding to create an embedding vector.

    .EXAMPLE
    New-TuneEmbedding -Query "brown fox"

    This command creates a query embedding vector that can be used to search for semantically similar text.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]$Text,
        [string]$Query,
        [ValidateSet(
            "text-embedding-ada-002",
            "text-search-ada-doc-001",
            "text-search-ada-query-001",
            "text-similarity-ada-001",
            "text-similarity-babbage-001",
            "text-similarity-curie-001",
            "text-similarity-davinci-001"
        )]
        [string]$Model,
        [switch]$Raw
    )
    begin {
        if (-not $Model) {
            if ($Text) {
                $Model = "text-embedding-ada-002"
            } else {
                $Model = "text-search-ada-query-001"
            }
        }
    }
    process {
        $url = "$script:baseUrl/embeddings"
        $body = @{
            model = $Model
            input = if ($Text) { $Text } else { $Query }
        } | ConvertTo-Json

        Write-Verbose "Creating embedding for: $body"

        $params = @{
            Uri         = $url
            Method      = "POST"
            ContentType = "application/json"
            Body        = $body
        }

        $result = Invoke-RestMethod2 @params
        if ($Raw) {
            $result
        } else {
            $result.data.embedding
        }
    }
}