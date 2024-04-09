function Get-TuneFile {
    <#
    .SYNOPSIS
    Retrieves a specific file from the API.

    .DESCRIPTION
    Sends a GET request to the API to retrieve a specified file.

    .PARAMETER Id
    The ID of the file to retrieve.

    .EXAMPLE
    Get-TuneFile

    .EXAMPLE
    Get-TuneFile -Id file-1234

    This command retrieves the file with the ID file-1234 from the API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("FileId", "file_id")]
        [string[]]$Id
    )
    process {
        if ($Id) {
            foreach ($fileid in $Id) {
                $url = "$script:baseUrl/files/$fileid"
                Write-Verbose "Getting $url"
                $params = @{
                    Uri    = $url
                    Method = "GET"
                }
                Invoke-RestMethod2 @params
            }
        } else {
            $url = "$script:baseUrl/files"
            Write-Verbose "Getting $url"
            $params = @{
                Uri        = $url
                Method     = "GET"
            }
            Invoke-RestMethod2 @params
        }
    }
}