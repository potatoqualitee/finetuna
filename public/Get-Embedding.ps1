function Get-Embedding {
<#
    .SYNOPSIS
    Creates an embedding vector for the given text using the OpenAI API.

    .DESCRIPTION
    The Get-Embedding command sends text to the OpenAI API to create an embedding vector.
    Embedding vectors can be used to measure semantic similarity between pieces of text.

    .PARAMETER Text
    The text to create an embedding for.

    .PARAMETER Model
    Optional. The name of the embedding model to use. Default is "text-embedding-ada-002".

    .EXAMPLE
    Get-Embedding -Text "The quick brown fox jumps over the lazy dog"

    This command creates an embedding vector for the given text.

    .EXAMPLE
    "The quick brown fox" | Get-Embedding

    This command pipes text to Get-Embedding to create an embedding vector.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias("Query")]
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
            $processedText = $processedText.Replace("`t", " ")
            $processedText.Replace("  ", " ")
        }
    }
    process {
        $preprocessText = Repair-Text -Text $Text

        Write-Verbose "Creating embedding for: $preprocessText"

        $params = @{
            Text  = $preprocessText
            Model = $Model
        }

        $result = Request-Embeddings @params
        if ($Raw) {
            $result
        } else {
            $result.data.embedding
        }
    }
}