function Get-TuneFileContent {
    <#
    .SYNOPSIS
    Retrieves the content of a specific file from the API.

    .DESCRIPTION
    Sends a GET request to the API to retrieve the content of a specified file.

    .PARAMETER Id
    The ID of the file to retrieve its content.

    .EXAMPLE
    "file-1234" | Get-TuneFileContent

    This command retrieves the content of the file with the ID file-1234 from the API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias("FileId", "file_id")]
        [string[]]$Id
    )
    process {
        foreach ($fileid in $Id) {
            $params = @{
                Uri    = "$script:baseUrl/files/$fileid/content"
                Method = "GET"
            }
            Invoke-RestMethod2 @params
        }
    }
}