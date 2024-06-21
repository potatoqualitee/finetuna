function Set-TuneModelDefault {
    <#
    .SYNOPSIS
    Sets the default model for fine-tuning operations.

    .DESCRIPTION
    Set-TuneModelDefault allows you to set the default model that will be used for fine-tuning operations when no specific model is specified.

    .PARAMETER Model
    The model to set as default. Can be one of the predefined models or a fine-tuned model (starting with "ft:").
    Default is "gpt-3.5-turbo-0125".

    .PARAMETER Latest
    If specified, sets the most recently created model as the default.

    .EXAMPLE
    Set-TuneModelDefault -Model gpt-3.5-turbo-0125

    Sets gpt-3.5-turbo-0125 as the default model for fine-tuning operations.

    .EXAMPLE
    Set-TuneModelDefault -Model ft:gpt-3.5-turbo-0613:my-org:custom_model:7p4lURx

    Sets a custom fine-tuned model as the default for fine-tuning operations.

    .EXAMPLE
    Set-TuneModelDefault -Latest

    Sets the most recently created model as the default for fine-tuning operations.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $script:ValidModels | Where-Object { $_ -like "$WordToComplete*" }
            })]
        [ValidateScript({ ValidateModelName $_ })]
        [Alias("ModelName", "model_name", "id")]
        [string]$Model = "gpt-3.5-turbo-0125",
        [switch]$Latest
    )
    process {
        if ($Latest) {
            $last = Get-TuneModel | Select-Object -Last 1
            $script:currentModel = $last.id
            Write-Verbose "Setting default model to the latest: $script:currentModel"
            $last
        } else {
            $script:currentModel = $Model
            Write-Verbose "Setting default model to $Model"
            Get-TuneModel -Model $Model
        }
    }
}
