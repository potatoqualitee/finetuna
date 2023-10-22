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
        [switch]$Custom
    )
    process {
        if ($Model) {
            foreach ($modelname in $Model) {
                $url = "https://api.openai.com/v1/models/$modelname"
                Write-Verbose "Getting $url"
                $params = @{
                    Uri    = $url
                    Method = "GET"
                }

                if ($Custom) {
                    Invoke-RestMethod2 @params | Where-Object owned_by -notmatch "openai|system"
                } else {
                    Invoke-RestMethod2 @params
                }
            }
        } else {
            $url = "https://api.openai.com/v1/models"
            Write-Verbose "Getting $url"
            $params = @{
                Uri    = $url
                Method = "GET"
            }
            if ($Custom) {
                Invoke-RestMethod2 @params | Where-Object owned_by -notmatch "openai|system"
            } else {
                Invoke-RestMethod2 @params
            }
        }
    }
}
