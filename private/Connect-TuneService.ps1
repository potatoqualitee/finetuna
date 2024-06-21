function Connect-TuneService {
    <#
    .SYNOPSIS
    Connects to a specified AI model service.

    .DESCRIPTION
    Connect-TuneService establishes a connection to the AI service using the specified model. It supports both predefined and fine-tuned models.

    .PARAMETER Url
    The URL of the API endpoint. By default, it uses the chat completions endpoint.

    .PARAMETER Model
    The model to connect to. Can be one of the predefined models or a fine-tuned model (starting with "ft:").

    Default is "gpt-3.5-turbo-0125".

    .EXAMPLE
    Connect-TuneService -Model "gpt-3.5-turbo-0125"

    Connects to the gpt-3.5-turbo-0125 model.

    .EXAMPLE
    Connect-TuneService -Model "ft:gpt-3.5-turbo-0613:my-org:custom_model:7p4lURx"

    Connects to a custom fine-tuned model.
    #>
    [CmdletBinding()]
    param(
        [string]$Url = "$script:baseUrl/chat/completions",
        [Parameter(Position = 0)]
        [ArgumentCompleter({
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $script:ValidModels | Where-Object { $_ -like "$WordToComplete*" }
            })]
        [ValidateScript({ ValidateModelName $_ })]
        [string]$Model = "gpt-3.5-turbo-0125"
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

    $Provider = Get-TuneProvider

    switch ($Provider.ApiType) {
        'OpenAI' {
            $headers['Authorization'] = "Bearer $($Provider.ApiKey)"
        }

        'Azure' {
            $headers['api-key'] = $Provider.ApiKey

            if ($Body -isnot [System.IO.Stream]) {
                if ($null -ne $Body -and $Body.Contains("model") ) {
                    $Body.model = $Provider.Deployment
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
            $Url = "{0}/openai{1}{2}api-version={3}" -f $Provider.ApiBase,
            $Url,
            $separator,
            $Provider.ApiVersion
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