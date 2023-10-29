function Invoke-TuneChat {
    <#
    .SYNOPSIS
    Invokes a chat with OpenAI using the specified model and messages.

    .DESCRIPTION
    The Invoke-TuneChat function sends a series of messages to the OpenAI API using the specified model.
    The messages are processed in the order they are received, and the response from the API is returned.

    .PARAMETER Message
    An array of messages to be sent to the OpenAI API. Each message should be a hashtable with 'role' and 'content' keys.

    .PARAMETER Model
    The model to be used for the chat. Valid options are 'gpt-3.5-turbo-0613', 'babbage-002', and 'davinci-002'.

    .PARAMETER MaxTokens
    The maximum number of tokens to be returned by the API. Defaults to 256.

    .PARAMETER Raw
    Returns the raw response from the API.

    .EXAMPLE
    Invoke-TuneChat -Message "How do I install dbatools?"

    This example sends a message to the OpenAI API using the default model and returns the response.

    .EXAMPLE
    Invoke-TuneChat -Message "How do I install dbatools?" -Verbose

    See what's going on behind the scenes, including token usage.

    .EXAMPLE
    Invoke-TuneChat -Message @(@{role='system'; content='You are a helpful assistant.'}, @{role='user'; content='Who won the world series in 2020?'}) -Model 'gpt-3.5-turbo-0613'

    This example sends two messages to the OpenAI API using the 'gpt-3.5-turbo-0613' model and returns the response.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]$Message = @("how's Potato?"),
        [string]$Model = $script:currentmodel,
        [int]$MaxTokens = 256,
        [switch]$Raw
    )
    begin {
        $jsonmsg = @()
        # sometimes it disappears?
        if (-not $Message) {
            $Message = @("how's Potato?")
        }
        foreach ($msg in $Message) {
            $jsonmsg += @{
                role    = "user"
                content = $msg
            }
        }
    }
    process {
        $body = @{
            model      = $Model
            messages   = $jsonmsg
            max_tokens = $MaxTokens
        }
        Write-Verbose "Chatting using model $Model"
        Write-Verbose "Max tokens: $MaxTokens"
        Write-Verbose "Body: $($body | ConvertTo-Json)"
        # Create a hashtable containing the parameters
        $params = @{
            Uri        = "https://api.openai.com/v1/chat/completions"
            Method     = "POST"
            Body       = ($body | ConvertTo-Json)
        }

        Write-Verbose "Asking: $Message"
        if ($Raw) {
            Invoke-OpenAIAPI @params
        } else {
            $results = Invoke-OpenAIAPI @params
            Write-Verbose "Prompt tokens: $($results.usage.prompt_tokens)"
            Write-Verbose "Completion tokens: $($results.usage.completion_tokens)"
            Write-Verbose "Total tokens: $($results.usage.total_tokens)"

            $results.choices.message.content
        }
    }
}