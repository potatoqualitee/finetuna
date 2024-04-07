function Invoke-TuneBotChat {
    <#
    .SYNOPSIS
    Invokes a chat with OpenAI using the specified model and messages.

    .DESCRIPTION
    The Invoke-TuneBotChat function sends a series of messages to the OpenAI API using the specified model.
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
    Invoke-TuneBotChat -Message "How do I install dbatools?"

    This example sends a message to the OpenAI API using the default model and returns the response.

    .EXAMPLE
    Invoke-TuneBotChat -Message "How do I install dbatools?" -Verbose

    See what's going on behind the scenes, including token usage.

    .EXAMPLE
    Invoke-TuneBotChat -Message @(@{role='system'; content='You are a helpful assistant.'}, @{role='user'; content='Who won the world series in 2020?'}) -Model 'gpt-3.5-turbo-0613'

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
        foreach ($msg in $Message) {
            $jsonmsg += @{
                role         = "user"
                content      = $msg
            }
        }

        if (-not $script:threadid) {
            # Create a hashtable containing the parameters
            $params = @{
                Uri    = "https://api.openai.com/v1/threads"
                Method = "POST"
            }
            $script:threadid = Invoke-RestMethod2 @params | Select-Object -First 1 -ExpandProperty id
        }
    }
    process {
        $params = @{
            Uri    = "https://api.openai.com/v1/assistants"
            Method = "GET"
        }
        # asst_d8bXKteFvWSQQkJ8zOFRi5sx
        #Invoke-RestMethod2 @params
        <#
        id           : asst_d8bXKteFvWSQQkJ8zOFRi5sx
        object       : assistant
        created_at   : 1699468550
        name         : Alphonse with Cookbooks
        description  :
        model        : gpt-4-1106-preview
        instructions : xyz
        tools        : {@{type=code_interpreter}, @{type=retrieval}}
        file_ids     : {file-mtc6Fgq1xhUZjDAU6k2SBFpS, file-FmAMfIX67EKNmLdJ0YgVRSaQ,
                    file-fAoY5YXm7ugHcTIUgq5XN6iz, file-uqBXDShC4gFmxTauzgfx5yfY...}
        metadata     :
        #>


        Write-Verbose "Body: $($body | ConvertTo-Json)"
        Write-Verbose "Thread ID: $script:threadid"
        $params = @{
            Uri    = "https://api.openai.com/v1/threads/$script:threadid/messages"
            Method = "POST"
            Body   = ($jsonmsg | ConvertTo-Json)
        }

        $messages = Invoke-RestMethod2 @params
        $msgid = $messages.id
        Write-Verbose "Message ID: $msgid"

        $params = @{
            Uri    = "https://api.openai.com/v1/threads/$script:threadid/runs"
            Method = "POST"
            Body   = @{
                assistant_id = "asst_d8bXKteFvWSQQkJ8zOFRi5sx"
            } | ConvertTo-Json
        }

        $run = Invoke-RestMethod2 @params
        $runid = $run.id
        Write-Verbose "Run ID: $runid"

        do {
            ## do a loop while you wait for $run.status to be "completed"
            $params = @{
                Uri    = "https://api.openai.com/v1/threads/$script:threadid/runs/$runid"
                Method = "GET"
            }

            $run = Invoke-RestMethod2 @params
        } while ($run.status -ne "completed")

        $params = @{
            Uri    = "https://api.openai.com/v1/threads/$script:threadid/messages?before=$msgid&limit=1"
            Method = "GET"
        }

        (Invoke-RestMethod2 @params).content.text.value

        <#
        {
        "object": "list",
        "data": [
            {
            "id": "msg_B9Pfg3FBI7SiQnLYeWenR26I",
            "object": "thread.message",
            "created_at": 1699477994,
            "thread_id": "thread_ju7PTDc3R9zWAdCM6rnMLhuS",
            "role": "assistant",
            "content": [
                {
                "type": "text",
                "text": {
                    "value": "Alright, take your time, baw. If y'all need help testin' specifically with any Cajun recipes or anything 'bout our culture, I'm here to help ya out. If there's a dish from down here in Acadiana you want to try, just let me know!",
                    "annotations": []
                }
                }
            ],
            "file_ids": [],
            "assistant_id": "asst_d8bXKteFvWSQQkJ8zOFRi5sx",
            "run_id": "run_ti5LcwuOVXhWcpbzZeH6CI4p",
            "metadata": {}
            }
        ],
        "first_id": "msg_B9Pfg3FBI7SiQnLYeWenR26I",
        "last_id": "msg_B9Pfg3FBI7SiQnLYeWenR26I",
        "has_more": false
        }
        #>



        <#
        const run = await openai.beta.threads.runs.create(
            thread.id,
            {
                assistant_id: assistant.id,
                instructions: "Please address the user as Jane Doe. The user has a premium account."
            }
        );
        #>
    }
}