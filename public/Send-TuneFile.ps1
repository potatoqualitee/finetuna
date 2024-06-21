function Send-TuneFile {
    <#
        .SYNOPSIS
            Uploads files to OpenAI for fine-tuning.

        .DESCRIPTION
            The Send-TuneFile cmdlet uploads specified files to OpenAI for fine-tuning.

        .PARAMETER FilePath
            Path to the file(s) to be uploaded.

        .PARAMETER WhatIf
            Shows what would happen if the cmdlet runs. The cmdlet is not run.

        .PARAMETER Confirm
            Prompts you for confirmation before running the cmdlet.

        .EXAMPLE
            Get-ChildItem *.jsonl | Send-TuneFile

        .EXAMPLE
            Send-TuneFile -FilePath C:\path\to\file.jsonl

        .EXAMPLE
            Send-TuneFile -FilePath C:\path\to\file.jsonl -WhatIf

            Shows what would happen if the cmdlet runs, but does not execute the cmdlet.

        .EXAMPLE
            Send-TuneFile -FilePath C:\path\to\file.jsonl -Confirm

            Prompts for confirmation before executing the cmdlet.
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path $_ })]
        [System.IO.FileInfo[]]$FilePath
    )
    process {
        foreach ($file in $FilePath) {
            if ($PSCmdlet.ShouldProcess("File: $($file.FullName)", 'Upload for fine-tuning')) {
                $params = @{
                    File    = $file.FullName
                    Purpose = "fine-tune"
                }
                Add-OpenAIFile @params
            }
        }
    }
}