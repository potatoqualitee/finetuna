function Connect-TuneService {
    <#
    .SYNOPSIS
    This function connects to a specified AI model service using an API key.

    .DESCRIPTION
    Connect-TuneService uses the provided API key and model type to establish a connection to the AI service. If you don't provide an API key, it will use the environment variable OpenAIKey. The model to connect can be 'gpt-3.5-turbo', 'babbage-002', or 'davinci-002'. The default model is 'gpt-3.5-turbo'.

    .PARAMETER ApiKey
    The API key used for connecting to the AI service. If you don't specify an API key, it will use the OpenAIKey environment variable.

    .PARAMETER Model
    The model you want to connect to. This can be 'gpt-3.5-turbo', 'babbage-002', or 'davinci-002'. The default is 'gpt-3.5-turbo'.

    .EXAMPLE
    Connect-TuneService -ApiKey "your-api-key-here" -Model "gpt-3.5-turbo"

    This example connects to the 'gpt-3.5-turbo' model using the specified API key.

    .EXAMPLE
    Connect-TuneService

    This example uses the OpenAIKey environment variable to connect to the default 'gpt-3.5-turbo' model.
#>
    [CmdletBinding()]
    param(
        [string]$ApiKey = $env:OpenAIKey,
        [ValidateSet("gpt-3.5-turbo", "babbage-002", "davinci-002")]
        [string]$Model = "gpt-3.5-turbo"
    )

    # Validate the API key
    if (-not $ApiKey) {
        throw "API key is not set. Cannot connect to OpenAI API."
    }

    # Set the headers for the WebSession
    $headers = @{
        Authorization  = "Bearer $ApiKey"
        "Content-Type" = "application/json"
    }

    # Test the connection
    $url = "https://api.openai.com/v1/chat/completions"

    $body = @{
        model       = $Model
        messages    = @(@{
            role = "user"
            content = "how's potato'"
        })
        max_tokens = 5
    } | ConvertTo-Json

    Write-Verbose "No connection yet, testing connection to OpenAI"
    $parms = @{
        Method          = "POST"
        Uri             = $url
        Headers         = $headers
        Body            = $body
        WebSession      = $null
        SessionVariable = "script:WebSession"
    }

    Invoke-RestMethod @parms
    $PSDefaultParameterValues["*:WebSession"] = $script:WebSession
}
