function Start-TuneJob {
    <#
    .SYNOPSIS
    Starts a new fine-tuning job.

    .DESCRIPTION
    Start-TuneJob initiates a new fine-tuning job using the specified file and model.

    .PARAMETER FileId
    The file ID of the training file. This parameter allows manual specification of the file ID and can be piped in.

    .PARAMETER Model
    The model to be used for tuning. Can be one of the predefined models or a fine-tuned model (starting with "ft:").
    Default is "gpt-3.5-turbo-0125".

    .PARAMETER Wait
    If specified, the function will wait for the fine-tuning job to complete before returning.

    .EXAMPLE
    Start-TuneJob -FileId file-abc123 -Model gpt-3.5-turbo-0125

    Starts a new fine-tuning job using the specified file and the gpt-3.5-turbo-0125 model.

    .EXAMPLE
    Get-TuneFile | Where-Object Name -eq "training_data.jsonl" | Start-TuneJob -Model ft:gpt-3.5-turbo-0613:my-org:custom_model:7p4lURx -Wait

    Starts a new fine-tuning job using the file named "training_data.jsonl" and a custom fine-tuned model, and waits for the job to complete.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("training_file", "Id")]
        [string[]]$FileId,
        [Parameter(Position = 0)]
        [ArgumentCompleter({
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $script:ValidModels | Where-Object { $_ -like "$WordToComplete*" }
            })]
        [string]$Model = "gpt-3.5-turbo-0125",
        [Parameter()]
        [switch]$Wait
    )
    process {
        foreach ($id in $FileId) {
            if ($PSCmdlet.ShouldProcess("File ID: $id for Model Tuning", 'Start')) {
                $OpenAIParameter = Get-OpenAIAPIParameter -EndpointName FineTuning.Jobs

                $PostBody = [System.Collections.Specialized.OrderedDictionary]::new()
                $PostBody.training_file = $id
                $PostBody.model = $Model

                $params = @{
                    Method       = 'POST'
                    Uri          = $OpenAIParameter.Uri
                    Body         = $PostBody
                    ApiKey       = $OpenAIParameter.ApiKey
                    AuthType     = $OpenAIParameter.AuthType
                    Organization = $OpenAIParameter.Organization
                }
                $job = Invoke-OpenAIAPIRequest @params | ConvertFrom-Json

                if ($Wait) {
                    $job | Wait-TuneJob
                } else {
                    $job
                }
            }
        }
    }
}