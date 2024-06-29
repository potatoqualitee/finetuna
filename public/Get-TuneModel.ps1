function Get-TuneModel {
    <#
    .SYNOPSIS
    Retrieves a specific model from the API.

    .DESCRIPTION
    Sends a GET request to the API to retrieve a specified model.

    .PARAMETER Model
    The name of the model to retrieve.

    .PARAMETER Custom
    Indicates whether to retrieve only custom models. When the switch is provided, the command filters out models owned by OpenAI or the system, returning only those models that are custom-made by the user.

    .PARAMETER Latest
    Indicates whether to retrieve only the latest version of the model. When the switch is provided, the command filters out all but the latest version of the model.

    .EXAMPLE
    Get-TuneModel

    .EXAMPLE
    Get-TuneModel -Model text-davinci-002

    This command retrieves the model with the name text-davinci-002 from the API.

    .EXAMPLE
    Get-TuneModel -Custom

    This command gets just the custom models from the API.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("ModelName", "model_name")]
        [string[]]$Model,
        [switch]$Custom,
        [switch]$Latest
    )
    begin {
        $PSDefaultParameterValues["Get-OpenAIModel:Raw"] = $true
    }
    process {
        if ($Model) {
            foreach ($modelname in $Model) {
                if ($Custom) {
                    (Get-OpenAIModel -Name $modelname).data | Where-Object owned_by -notmatch "openai|system"
                } elseif ($Latest) {
                    (Get-OpenAIModel -Name $modelname).data | Select-Object -Last 1
                } else {
                    (Get-OpenAIModel -Name $modelname).data
                }
            }
        } else {

            if ($Custom) {
                (Get-OpenAIModel).data | Where-Object owned_by -notmatch "openai|system"
            } elseif ($Latest) {
                (Get-OpenAIModel).data | Select-Object -Last 1
            } else {
                (Get-OpenAIModel).data
            }
        }
    }
}
