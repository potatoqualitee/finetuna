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

    .EXAMPLE
    Invoke-TuneChat -Message @(@{role='system'; content='You are a helpful assistant.'}, @{role='user'; content='Who won the world series in 2020?'}) -Model 'gpt-3.5-turbo-0613'

    This example sends two messages to the OpenAI API using the 'gpt-3.5-turbo-0613' model and returns the response.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]$Message = @("how's Potato?"),
        [string]$Model = $script:currentmodel
    )
    begin {
        if (-not $Model) {
            $Model = "gpt-3.5-turbo-0613"
        }
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
        } | ConvertTo-Json

        Write-Verbose "Chatting using model $Model"
        # Create a hashtable containing the parameters
        $params = @{
            Uri        = "https://api.openai.com/v1/chat/completions"
            Method     = "POST"
            Body       = $body
        }

        Write-Verbose "Asking: $Message"
        (Invoke-OpenAIAPI @params).choices.message.content
    }
}