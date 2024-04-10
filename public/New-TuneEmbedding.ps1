function New-TuneEmbedding {
<#
    .SYNOPSIS
    Creates an embedding vector for the given text using the OpenAI API.

    .DESCRIPTION
    The New-TuneEmbedding cmdlet sends text to the OpenAI API to create an embedding vector.
    Embedding vectors can be used to measure semantic similarity between pieces of text.

    .PARAMETER Text
    The text to create an embedding for.

    .PARAMETER Model
    Optional. The name of the embedding model to use. Default is "text-embedding-ada-002".

    .EXAMPLE
    New-TuneEmbedding -Text "The quick brown fox jumps over the lazy dog"

    This command creates an embedding vector for the given text.

    .EXAMPLE
    "The quick brown fox" | New-TuneEmbedding

    This command pipes text to New-TuneEmbedding to create an embedding vector.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Text,
        [ValidateSet(
            "text-embedding-ada-002",
            "text-embedding-3-small",
            "text-embedding-3-large"
        )]
        [string]$Model = "text-embedding-3-small",
        [switch]$Raw
    )
    begin {
        function Repair-Text {
            param (
                [string]$Text
            )

            # Lowercase the text
            $processedText = $Text.ToLower()

            # Define a list of stop words. You might need to expand this list based on your context.
            $stopWords = @("the", "is", "at", "which", "on", "and", "a", "to")

            # Remove stop words
            $processedText = $processedText.Split(' ').Where({ $PSItem -notin $stopWords })
            $processedText = $processedText -join ' '

            # Remove special characters, preserving PowerShell-specific ones like '-', '_'
            # Adjust the regex to keep hyphens and underscores
            $processedText = $processedText -replace '[^\w\s\-_]', ''

            return $processedText
        }
    }
    process {
        $preprocessText = Repair-Text -Text $Text
        $url = "$script:baseUrl/embeddings"
        $body = @{
            model = $Model
            input = $preprocessText
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
            $result.embedding
        }
    }
}