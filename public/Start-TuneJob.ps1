function Start-TuneJob {
    <#
    .SYNOPSIS
        Initiates model tuning using a specified file ID.

    .DESCRIPTION
        This command accepts a file ID to start the model tuning process via a POST request to the OpenAI API.

    .PARAMETER FileId
        The file ID of the training file. This parameter allows manual specification of the file ID and can be piped in.

    .PARAMETER Model
        The model to be used for tuning. Default is 'gpt-3.5-turbo-0613'. Your custom models can be reused, fa sho.

    .PARAMETER WhatIf
        Shows what would happen if the cmdlet runs. The cmdlet is not run.

    .PARAMETER Confirm
        Prompts you for confirmation before running the cmdlet.

    .EXAMPLE
        Start-TuneJob -FileId file-g8qyzvm2hxPxK1iwVaTX6Z3E

        This example demonstrates manually specifying the file ID to initiate the model tuning process.

    .EXAMPLE
        Send-TuneFile -FilePath C:\path\to\file.json | Start-TuneJob -Model ft:gpt-3.5-turbo-0613:personal::8COaNMYp

        This example demonstrates piping the file ID to Start-TuneJob to initiate the model tuning process against a pre-trained custom model.

    .EXAMPLE
        Start-TuneJob -FileId file-g8qyzvm2hxPxK1iwVaTX6Z3E -WhatIf

        Shows what would happen if the cmdlet runs, but does not execute the cmdlet.

    .EXAMPLE
        Start-TuneJob -FileId file-g8qyzvm2hxPxK1iwVaTX6Z3E -Confirm

        Prompts for confirmation before executing the cmdlet.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("training_file", "Id")]
        [string[]]$FileId,
        [string]$Model = 'gpt-3.5-turbo-0613'
    )
    process {
        foreach ($id in $FileId) {
            if ($PSCmdlet.ShouldProcess("File ID: $id for Model Tuning", 'Start')) {
                $body = @{
                    training_file = $id
                    model         = $Model
                } | ConvertTo-Json

                $params = @{
                    Uri         = "https://api.openai.com/v1/fine_tuning/jobs"
                    Method      = "POST"
                    Body        = $body
                    ContentType = "application/json"
                }

                Invoke-RestMethod2 @params
            }
        }
    }
}