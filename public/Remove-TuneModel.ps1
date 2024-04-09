function Remove-TuneModel {
    <#
    .SYNOPSIS
    Removes a specific model from the API.

    .DESCRIPTION
    Sends a DELETE request to the API to remove a specified model.

    .PARAMETER Model
    The name of the model to remove.

    .PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.

    .PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.

    .EXAMPLE
    Remove-TuneModel -Model ft:gpt-3.5-turbo-0613:personal::8CUJeKeP

    This command removes the model with the name ft:gpt-3.5-turbo-0613:personal::8CUJeKeP from the API.

    .EXAMPLE
    Get-TuneModel -Custom | Remove-TuneModel -Confirm:$false

    Deletes all of your custom models and does not prompt for confirmation.

    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias("ModelName", "model_name", "id")]
        [string[]]$Model
    )
    process {
        foreach ($modelname in $Model) {
            $url = "$script:baseUrl/models/$modelname"
            if ($PSCmdlet.ShouldProcess("Model: $modelname", 'Remove')) {
                Write-Verbose "Removing $modelname"
                $params = @{
                    Uri    = $url
                    Method = "DELETE"
                }
                Invoke-RestMethod2 @params
            }
        }
    }
}
