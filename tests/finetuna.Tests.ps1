
BeforeEach {
    if (-not $env:OPENAI_API_KEY) {
        throw "OPENAI_API_KEY environment variable is not set."
    }
    Import-Module ./finetuna.psd1
    $global:OPENAI_API_KEY = $PSDefaultParameterValues['Initialize-APIKey:ApiKey'] = $env:OPENAI_API_KEY
    $script:sampleFilePath = Get-ChildItem -Recurse totbot-tee-tune.jsonl
    $splat = @{
        ApiType = 'openai'
        ApiKey  = $env:OPENAI_API_KEY
    }
    Set-TuneProvider @splat
}

Describe "finetuna Module Tests" {
    Context "Clear-TuneProvider" {
        It "Should clear the provider configuration" {
            Clear-TuneProvider
            $provider = Get-TuneProvider
            $provider.ApiKey | Should -BeNullOrEmpty
            $provider.ApiType | Should -BeNullOrEmpty
        }
    }
    Context "Set-TuneProvider" {
        It "Should set the API key and configuration" {
            $splat = @{
                ApiType = 'openai'
                ApiKey  = $env:OPENAI_API_KEY
            }
            $provider = Set-TuneProvider @splat
            $provider.ApiKey | Should -Not -BeNullOrEmpty
            $provider.ApiType | Should -Be 'openai'
            (Get-OpenAIContext).ApiKey | Should -Not -BeNullOrEmpty
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
            Get-TuneJob | Where-Object status -notin 'failed', 'succeeded' | Stop-TuneJob -Confirm:$false
            $file = Get-TuneFile | Where-Object { $_.filename -eq "totbot-tee-tune.jsonl" }
            $result = Start-TuneJob -FileId $file.id -Model "gpt-3.5-turbo-0613"
            $result.id | Should -Match '^ftjob-'
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
            $result = Invoke-TuneChat -Message "Test message"
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
            $file = Get-TuneFile | Where-Object filename -eq totbot-tee-tune.jsonl
            $result = $file | Remove-TuneFile -Confirm:$false
            $result.Status | Should -Be 'Removed'
        }
    }

    Context "Get-Embedding" {
        It "Should generate an embedding for the given text" {
            $result = Get-Embedding -Text "Hello, world!"
            $result | Should -Not -BeNullOrEmpty
            $PSDefaultParametervalues
        }
    }


    Context "Compare-Embedding" {
        It "Should compare embeddings and return similarities" {
            $embeddings = @{
                "hello" = Get-Embedding -Text "hello"
                "hi"    = Get-Embedding -Text "hi"
            }
            $result = Compare-Embedding -Query "greeting" -Embeddings $embeddings
            $result.Similarity | Should -Not -BeNullOrEmpty
        }
    }
    Context "Get-TuneFileContent" {
        It "Should retrieve the content of a file" {
            $file = Get-TuneFile | Select-Object -First 1
            $result = Get-TuneFileContent -Id $file.id
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "Get-TuneJobEvent" {
        It "Should retrieve the events of a fine-tuning job" {
            $job = Get-TuneJob | Select-Object -First 1
            $result = Get-TuneJobEvent -Id $job.id
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "Get-TuneModelDefault" {
        It "Should retrieve the default model" {
            $result = Get-TuneModelDefault
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "Measure-TuneToken" {
        It "Should measure the token count and cost estimates for the given text" {
            $result = Measure-TuneToken -InputObject "Hello, world!"
            $result.TokenCount | Should -BeGreaterThan 0
        }
    }

    Context "Request-TuneFileReview" {
        It "Should request a file review and provide improvement suggestions" {
            $result = Request-TuneFileReview -FilePath $sampleFilePath
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "Set-TuneModelDefault" {
        It "Should set the default model" {
            $model = Get-TuneModel | Select-Object -First 1
            Set-TuneModelDefault -Model $model.id
            $result = Get-TuneModelDefault
            $result | Should -Be $model.id
        }
    }

    Context "Test-TuneFile" {
        It "Should test the validity of a tune file" {
            $result = Test-TuneFile -FilePath $sampleFilePath
            $result.IsValid | Should -Be $true
        }
    }
}