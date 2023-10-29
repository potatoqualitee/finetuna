function Set-TuneModelDefault {
    <#
    .SYNOPSIS
    Sets your preferred model as the default, making it easier to manage and interact with that model in future tasks.

    .DESCRIPTION
    This command helps you set a default model that you'll use often, saving you time and effort. Once a default model is set, it becomes your go-to model for various operations, streamlining your workflow. The command also returns details of the newly set default model for your reference.

    .PARAMETER Model
    The name of the model to set as default.

    .PARAMETER Latest
    Use this switch to automatically set the most recently created model as the default. This is helpful when you've created multiple models and want to quickly switch to using the latest one.

    .EXAMPLE
    Set-TuneModelDefault -Model text-davinci-002

    This command sets the model with the name text-davinci-002 as the default model.

    .EXAMPLE
    Get-TuneModel | Out-GridView -Passthru | Set-TuneModelDefault

    This command sets the model obtained from Get-TuneModel as the default.

    .EXAMPLE
    Set-TuneModelDefault -Latest

    This command sets the most recently created model as the default, making it easier to start using new models right away.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("ModelName", "model_name", "id")]
        [string]$Model = "gpt-4-0613",
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
