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
        [string]$Url = "$script:baseUrl/chat/completions",
        [ValidateSet("gpt-3.5-turbo", "babbage-002", "davinci-002")]
        [string]$Model = "gpt-3.5-turbo"
    )

    # Set the headers for the WebSession
    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        model       = $Model
        messages    = @(@{
            role = "user"
            content = "hi"
        })
        max_tokens = 5
    } | ConvertTo-Json

    $Provider = Get-OAIProvider
    $AzOAISecrets = Get-AzOAISecrets
    switch ($Provider) {
        'OpenAI' {
            $headers['Authorization'] = "Bearer $env:OpenAIKey"
        }

        'AzureOpenAI' {
            $headers['api-key'] = "$($AzOAISecrets.apiKEY)"

            if ($Body -isnot [System.IO.Stream]) {
                if ($null -ne $Body -and $Body.Contains("model") ) {
                    $Body.model = $AzOAISecrets.deploymentName
                }
            }

            $Url = $Url -replace $baseUrl, ''
            if ($Url.EndsWith('/')) {
                $Url = $Url.Substring(0, $Url.Length - 1)
            }

            $separator = '?'
            if ($Url.Contains('?')) {
                $separator = '&'
            }
            $Url = "{0}/openai{1}{2}api-version={3}" -f $AzOAISecrets.apiURI,
            $Url,
            $separator,
            $AzOAISecrets.apiVersion
        }
    }

    Write-Verbose "No connection yet, testing connection to API"
    $parms = @{
        Method          = "POST"
        Uri             = $Url
        Headers         = $headers
        Body            = $body
        WebSession      = $null
        SessionVariable = "script:WebSession"
    }

    Invoke-RestMethod @parms
    $PSDefaultParameterValues["*:WebSession"] = $script:WebSession
}
