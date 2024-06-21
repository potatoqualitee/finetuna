Describe "finetuna Module" {
    BeforeAll {
        $modulePath = Join-Path -Parent ($PSScriptRoot | Split-Path) -Child finetuna.psd1
        Import-Module $modulePath -Force
    }

    Context "New-TuneModel (Create-CustomModel)" {
        It "Should create a new fine-tuned model" {
            # Create a test JSONL file
            $testFile = Join-Path $TestDrive "test.jsonl"
            '{"messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "Hello"}, {"role": "assistant", "content": "Hi there! How can I assist you today?"}]}' | Set-Content $testFile

            # Create a new fine-tuned model
            $model = New-TuneModel -FilePath $testFile
            $model | Should -Not -BeNullOrEmpty
            $model.id | Should -BeLike "ft:*"
        }
    }

    Context "Invoke-TuneChat" {
        It "Should return a response from the fine-tuned model" {
            # Use the default model
            $response = Invoke-TuneChat -Message "Hello, how are you?"
            $response | Should -Not -BeNullOrEmpty
        }
    }

    Context "Get-TuneFile" {
        It "Should retrieve the list of files" {
            $files = Get-TuneFile
            $files | Should -Not -BeNullOrEmpty
            $files[0].id | Should -BeLike "file-*"
        }
    }

    Context "Measure-TuneToken" {
        It "Should return token count and cost estimates" {
            $result = Measure-TuneToken -InputObject "Hello, world!"
            $result.TokenCount | Should -BeGreaterThan 0
            $result.TrainingCost | Should -Not -BeNullOrEmpty
            $result.InputUsageCost | Should -Not -BeNullOrEmpty
            $result.OutputUsageCost | Should -Not -BeNullOrEmpty
        }
    }

    Context "Set-TuneModelDefault" {
        It "Should set the default model" {
            Set-TuneModelDefault -Model "gpt-3.5-turbo-0125"
            $defaultModel = Get-TuneModelDefault
            $defaultModel | Should -Be "gpt-3.5-turbo-0125"
        }
    }

    AfterAll {
        # Clean up
        Get-TuneModel -Custom | Remove-TuneModel -Confirm:$false
        Get-TuneFile | Remove-TuneFile -Confirm:$false
    }
}