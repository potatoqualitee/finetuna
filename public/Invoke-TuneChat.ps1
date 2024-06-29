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
    The model to be used for the chat.

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
        if (-not $script:jsonmsg -or $env:NoPersistence -eq $true) {
            $script:jsonmsg = New-Object System.Collections.ArrayList
        }
    }
    process {
        # sometimes it disappears?
        if (-not $Message) {
            $Message = @("how's Potato?")
        }

        $msgtoken = ($Message | Measure-TuneToken).TokenCount
        $totaltoken = ($script:jsonmsg | Measure-TuneToken).TokenCount

        if (($msgToken + $totalToken) -gt ($MaxTokens * 0.80)) {
            $limit = $MaxTokens * 0.80
            Write-Verbose "Token limit approaching, reducing cache"

            # Calculate the excess tokens
            $excessTokens = $msgToken + $totalToken - $limit

            # Iterate through the oldest messages and remove them until the token count is within the limit
            $removedTokens = 0
            for ($i = $script:jsonmsg.Count - 1; $i -ge 0; $i--) {
                $messageTokens = ($script:jsonmsg[$i] | Measure-TuneToken).TokenCount
                $removedTokens += $messageTokens

                # Remove the message if its tokens contribute to the excess
                if ($removedTokens -gt $excessTokens) {
                    $script:jsonmsg.RemoveRange(0, $i + 1)
                    Write-Verbose "Removed $($i + 1) oldest messages to reduce token count"
                    return
                }
            }
        }

        foreach ($msg in $Message) {
            # check for dupes
            $last = $script:jsonmsg | Select-Object -Last 1 -Skip 1
            if ($last.content -ne $msg) {
                $null = $script:jsonmsg.Add(@{
                        role    = "user"
                        content = $msg
                    })
            }
        }
        $body = @{
            model      = $Model
            messages   = $script:jsonmsg
            max_tokens = $MaxTokens
        }
        Write-Verbose "Chatting using model $Model"
        Write-Verbose "Max tokens: $MaxTokens"
        Write-Verbose "Body: $($body | ConvertTo-Json)"

        Write-Verbose "Asking: $Message"
        $splat = @{
            Message      = $Message
            Model        = $Model
            MaxTokens    = $MaxTokens
        }
        Request-ChatCompletion @splat

    }
}