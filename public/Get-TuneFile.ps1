function Get-TuneFile {
    <#
    .SYNOPSIS
    Retrieves a specific file or list of files from the OpenAI API.

    .DESCRIPTION
    The Get-TuneFile cmdlet sends a GET request to the OpenAI API to retrieve a specified file or list of files.

    .PARAMETER Id
    Optional ID or array of IDs of the file(s) to retrieve.

    .EXAMPLE
    Get-TuneFile

    This command retrieves a list of files from the OpenAI API.

    .EXAMPLE
    Get-TuneFile -Id "file-1234"

    This command retrieves the file with the ID "file-1234" from the OpenAI API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("FileId", "file_id")]
        [string[]]$Id
    )
    process {
        if ($Id) {
            foreach ($fileId in $Id) {
                Get-OpenAIFile -FileId $fileId
            }
        } else {
            Get-OpenAIFile
        }
    }
}