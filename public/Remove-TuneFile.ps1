function Remove-TuneFile {
    <#
    .SYNOPSIS
    Deletes a file using the OpenAI API.

    .DESCRIPTION
    The Remove-TuneFile cmdlet sends a DELETE request to the OpenAI API to delete a specified file.

    .PARAMETER Id
    The ID of the file to delete.

    .PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.

    .PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.

    .EXAMPLE
    Remove-TuneFile -Id file-1234

    This command deletes the file with the ID "file-1234" from the OpenAI API.

    .EXAMPLE
    Remove-TuneFile -Id file-1234 -WhatIf

    Shows what would happen if the cmdlet runs, but does not execute the cmdlet.

    .EXAMPLE
    Remove-TuneFile -Id file-1234 -Confirm:$false

    Doesn't prompt for confirmation before executing the cmdlet.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$Id
    )
    process {
        foreach ($fileId in $Id) {
            if ($PSCmdlet.ShouldProcess("File ID: $fileId", 'Remove')) {
                $null = Remove-OpenAIFile -FileId $fileId
                [pscustomobject]@{
                    File   = $fileId
                    Status = 'Removed'
                }
            }
        }
    }
}