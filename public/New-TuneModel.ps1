function New-TuneModel {
<#
    .SYNOPSIS
        Automates the entire fine-tuning process for an OpenAI model.

    .DESCRIPTION
        This command uploads a training file, starts a fine-tuning job, and monitors its progress.
        Once the job is complete, it sets the new fine-tuned model as the current model and notifies the user.

    .PARAMETER FilePath
        The path to the training file (.jsonl) used for fine-tuning.

    .PARAMETER Model
        The base model to use for fine-tuning. Defaults to gpt-3.5-turbo-0613.

    .PARAMETER Append
        Append all files to the same model. If this switch is not used, a new model will be created for each file.

    .PARAMETER WhatIf
        Shows what would happen if the cmdlet runs. The cmdlet is not run.

    .PARAMETER Confirm
        Prompts you for confirmation before running the cmdlet.

    .EXAMPLE
        New-TuneModel -FilePath .\sample\potato.jsonl -Model gpt-3.5-turbo-0613

        Uploads the potato.jsonl file and starts a fine-tuning job using the gpt-3.5-turbo-0613 model.

        .EXAMPLE
        Get-ChildItem *.jsonl | New-TuneModel -Model gpt-3.5-turbo-0613 -Append

        Pipes all .jsonl files in the current directory to New-TuneModel, appending them to the gpt-3.5-turbo-0613 model for fine-tuning, instead of creating a new model for each file.

    .EXAMPLE
        New-TuneModel -FilePath .\sample\potato.jsonl -Model gpt-3.5-turbo-0613 -WhatIf

        Shows what would happen if the cmdlet runs, but does not execute the cmdlet.

    .EXAMPLE
        New-TuneModel -FilePath .\sample\potato.jsonl -Model gpt-3.5-turbo-0613 -Confirm

        Prompts for confirmation before executing the cmdlet.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$FilePath,
        [string]$Model = 'gpt-3.5-turbo-0613',
        [switch]$Append
    )
    begin {
        if ($Append) {
            if ((Get-TuneModel -Model $Model -Custom)) {
                $system  = $false
            } else {
                $system = $true
            }
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess("Fine-tuning model $Model using training file $FilePath")) {
            # Upload the file and get the file ID
            $basename = Get-ChildItem $FilePath | Select-Object -ExpandProperty BaseName
            $fileId = Send-TuneFile -FilePath $FilePath | Select-Object -ExpandProperty Id
            Write-Verbose "Uploaded $FilePath with ID $fileId"

            # Start the tune job
            Write-Verbose "Starting fine-tuning job for $Model with FileId $fileId"
            $tuneJobId = Start-TuneJob -Id $fileId -Model $Model | Select-Object -ExpandProperty Id
            Write-Verbose "Started fine-tuning job $tuneJobId"

            # Initialize the progress bar
            $progress = @{
                Status          = "Waiting for fine-tuning for $basename to complete"
                Activity        = "Fine-tuning $Model"
                PercentComplete = 0
            }
            Write-Progress @progress

            # Check the status every 5 seconds
            do {
                $jobStatus = Get-TuneJob -Id $tuneJobId
                Write-Verbose "Got info for tune job $tuneJobId"

                # Update progress bar
                if ($true) {
                    $progress.PercentComplete = ($progress.PercentComplete) + 1
                }
                Write-Progress @progress

                if ($jobStatus.status -in "failed", "cancelled") {
                    <# statuses: running, succeeded, failed, cancelled #>
                    throw "Fine-tuning job $tuneJobId failed"
                    # not sure if it needs a throw and a break?
                    break
                }

                if ($jobStatus.status -eq "succeeded") {
                    if ($system -and $Append) {
                        $script:currentmodel = $Model = $jobStatus.fine_tuned_model
                        $system = $false
                    } else {
                        if (-not $Append) {
                            $script:currentmodel = $jobStatus.fine_tuned_model
                        }
                    }

                    $script:currentmodel = $jobStatus.fine_tuned_model
                    Write-Verbose "Your new model is named $script:currentmodel and will now be used when executing Invoke-TuneChat"

                    # Use ChatGPT to inform the user about the new model
                    Invoke-TuneChat -Message $message -Model $script:currentmodel
                    break
                } else {
                    Write-Verbose "Fine-tuning job $tuneJobId is still running"
                }

                # Restart progress if it gets to 100 without a fine_tuned_model value
                if ($progress.PercentComplete -ge 100) {
                    $progress.PercentComplete = 0
                }
                Start-Sleep -Seconds 5
            } while ($true)
        }
    }
}