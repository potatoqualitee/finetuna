Describe "finetuna Module Tests" {
    BeforeAll {
        $apiKey = $env:OPENAI_API_KEY

        if (-not $apiKey) {
            throw "OPENAI_API_KEY environment variable is not set."
        }
        Import-Module ./finetuna.psd1
        $parent = Split-Path $PSScriptRoot -Parent
        $samples = Join-Path -Parent $parent -ChildPath samples
        $sampleFilePath = Join-Path -Parent $samples -ChildPath totbot-tee-tune.jsonl

    }
    Context "Set-TuneProvider" {
        It "Should set the API key and configuration" {
            $splat = @{
                ApiType = 'openai'
                ApiKey  = $apiKey
            }
            $provider = Set-TuneProvider @splat
            $provider.ApiKey | Should -Not -BeNullOrEmpty
            $provider.ApiType | Should -Be 'openai'
        }
    }

    Context "Get-TuneProvider" {
        It "Should get the API key and configuration" {
            $provider = Get-TuneProvider
            $provider.ApiKey | Should -Not -BeNullOrEmpty
            $provider.ApiType | Should -Be 'openai'
        }
    }

    Context "Send-TuneFile" {
        It "Should upload a file for fine-tuning" {
            $result = Send-TuneFile -FilePath $sampleFilePath
            $result.id | Should -Match '^file-'
        }
    }

    Context "Get-TuneFile" {
        It "Should retrieve the list of files" {
            $files = Get-TuneFile
            $files | Should -Not -BeNullOrEmpty
        }
    }

    Context "Start-TuneJob" {
        It "Should start a fine-tuning job" {
            $file = Get-TuneFile | Where-Object { $_.filename -eq "totbot-tee-tune.jsonl" }
            $result = Start-TuneJob -FileId $file.id -Model "gpt-3.5-turbo-0613"
            $result.id | Should -Match '^ft-'
        }
    }

    Context "Get-TuneJob" {
        It "Should retrieve the status of a fine-tuning job" {
            $job = Get-TuneJob | Select-Object -First 1
            $job.status | Should -Not -BeNullOrEmpty
        }
    }

    Context "Wait-TuneJob" {
        It "Should wait for a fine-tuning job to complete" {
            $job = Get-TuneJob | Where-Object { $_.status -eq 'pending' } | Select-Object -First 1
            if ($job) {
                $result = Wait-TuneJob -JobId $job.id
                $result.status | Should -Be 'succeeded'
            }
        }
    }

    Context "Get-TuneModel" {
        It "Should retrieve the custom fine-tuned models" {
            $models = Get-TuneModel -Custom
            $models | Should -Not -BeNullOrEmpty
        }
    }

    Context "Invoke-TuneChat" {
        It "Should send a message to the fine-tuned model for chat completion" {
            $model = Get-TuneModel -Custom | Select-Object -First 1
            $result = Invoke-TuneChat -Message "Test message" -Model $model.id
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "Remove-TuneModel" {
        It "Should delete a fine-tuned model" {
            $model = Get-TuneModel -Custom | Select-Object -First 1
            $result = Remove-TuneModel -Model $model.id -Confirm:$false
            $result.Status | Should -Be 'Removed'
        }
    }

    Context "Remove-TuneFile" {
        It "Should delete a file used for fine-tuning" {
            $file = Get-TuneFile | Where-Object { $_.filename -eq "totbot-tee-tune.jsonl" }
            $result = Remove-TuneFile -Id $file.id -Confirm:$false
            $result.Status | Should -Be 'Removed'
        }
    }
}