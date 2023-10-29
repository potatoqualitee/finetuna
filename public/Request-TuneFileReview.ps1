function Request-TuneFileReview {
    <#
        .SYNOPSIS
            Submits a file to Invoke-TuneChat for improvement suggestions.

        .DESCRIPTION
            This function sends the contents of specified files to Invoke-TuneChat for analysis and suggestions for improvement.

        .PARAMETER FilePath
            Path to the files to be analyzed for improvements.

        .PARAMETER Model
            The model you want to use for the analysis. If not specified, the default model is used.

        .PARAMETER Prompt
            Custom prompt. The default asks for 5 improvements with corresponding json examples.

        .PARAMETER MaxTokens
            Limit the number of tokens in the response from Invoke-TuneChat. Default is 1024.

        .EXAMPLE
            Request-TuneFileReview -FilePath C:\path\to\file.jsonl

            Sends the content of the specified file to Invoke-TuneChat and displays improvement suggestions.

        .EXAMPLE
            Get-ChildItem *.jsonl | Request-TuneFileReview

            Sends the content of all .jsonl files in the current directory to Invoke-TuneChat and displays improvement suggestions for each.

        .EXAMPLE
            Request-TuneFileReview -FilePath C:\path\to\file.jsonl -Model "gpt-4" -MaxTokens 500

            Uses the GPT-4 model and limits the response to 500 tokens.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ return (Test-Path $_) })]
        [System.IO.FileInfo[]]$FilePath,
        [string]$Model,
        [string]$Prompt = "I have a JSONL file used for training a chatbot. Here's the content. Pls analyze it and suggest 5 improvements. After your review, please include corresponding examples in JSONL format.",
        [int]$MaxTokens = 1024
    )
    process {
        foreach ($file in $FilePath) {
            Write-Verbose "Processing $file"
            $file = (Get-ChildItem $file).FullName
            $basename = (Get-ChildItem $file).BaseName
            Write-Host "`r`n--- Results for $basename ---`r`n"

            $fileContent = Get-Content -Path $file -Raw
            $Prompt = "$Prompt

            $fileContent"

            if (-not $Model) {
                $Model = Get-TuneModelDefault
            }

            $params = @{
                Message   = $Prompt
                Model     = $Model
                MaxTokens = $MaxTokens
            }
            Invoke-TuneChat @params
        }
    }
}
