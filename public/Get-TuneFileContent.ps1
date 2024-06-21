function Get-TuneFileContent {
    <#
    .SYNOPSIS
    Retrieves the content of a specific file from the OpenAI API.

    .DESCRIPTION
    The Get-TuneFileContent gets the content of a specified file.

    .PARAMETER Id
    The ID of the file to retrieve its content.

    .EXAMPLE
    "file-1234" | Get-TuneFileContent

    This command retrieves the content of the file with the ID "file-1234" from the OpenAI API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelinebyPropertyName)]
        [Alias("FileId", "file_id")]
        [string[]]$Id
    )
    process {
        foreach ($fileId in $Id) {
            try {
                Get-OpenAIFileContent -FileId $fileId
            } catch {
                Write-Warning $PSItem
                continue
            }
        }
    }
}