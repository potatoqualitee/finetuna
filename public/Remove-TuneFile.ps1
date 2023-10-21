function Remove-TuneFile {
    <#
    .SYNOPSIS
    Deletes a file from the OpenAI API.

    .DESCRIPTION
    The Remove-TuneFile cmdlet sends a DELETE request to the OpenAI API to delete a specified file.

    .PARAMETER Id
    The ID of the file to delete.

    .EXAMPLE
    Remove-TuneFile -Id file-1234

    This command deletes the file with the ID "file-1234" from the OpenAI API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$Id
    )

    process {
        foreach ($fileid in $Id) {
            $params = @{
                Uri        = "https://api.openai.com/v1/files/$fileid"
                Method     = "DELETE"
            }
            Invoke-RestMethod2 @params
        }
    }
}