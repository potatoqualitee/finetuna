function Remove-TuneModel {
    <#
    .SYNOPSIS
    Deletes a fine-tuned model from OpenAI.

    .DESCRIPTION
    The Remove-TuneModel cmdlet sends a DELETE request to the OpenAI API to delete a specified fine-tuned model.

    .PARAMETER Model
    The name of the model to delete.

    .PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.

    .PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.

    .EXAMPLE
    Remove-TuneModel -Model "ft:gpt-3.5-turbo-0613:personal::8CUJeKeP"

    This command deletes the model with the name "ft:gpt-3.5-turbo-0613:personal::8CUJeKeP" from OpenAI.

    .EXAMPLE
    Get-TuneModel -Custom | Remove-TuneModel -Confirm:$false

    Deletes all custom fine-tuned models without prompting for confirmation.
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias("ModelName", "model_name", "id")]
        [string[]]$Model
    )
    process {
        foreach ($modelName in $Model) {
            if ($PSCmdlet.ShouldProcess("Model: $modelName", 'Delete')) {
                Remove-OpenAIModel -Model $modelName
            }
        }
    }
}