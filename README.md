# finetuna: Fine-tuned PowerShell module to Fine-Tune OpenAI Models

<p align="center">
  <img src="./logo.png"/>
</p>

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Command Overview](#command-overview)
- [Azure OpenAI Services](#azure-openai-services)
- [Configuration](#configuration)
- [Examples](#examples)
- [Removing Files and Models](#removing-files-and-models)

## Introduction

finetuna is designed to simplify the fine-tuning of OpenAI models. Train your models and interact with them—all through PowerShell.

Right now, the awesome functionality is that you can pipe a whole directory of jsonl files into a command that trains a whole new model/bot on those files.

## Prerequisites

- PowerShell (any version)
- OpenAI API Key or Azure OpenAI API Key

## Installation

1. **Set Execution Policy**:
   Run the following command if needed:
    ```powershell
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

2. **Install from PowerShell Gallery**:
    Run the following command:
    ```powershell
    Install-Module -Name finetuna
    ```
    Dependencies will be installed automatically.

3. **Get and set your OpenAI API Key**:
   Get/Create your OpenAI API key from [ https://platform.openai.com/account/api-keys]( https://platform.openai.com/account/api-keys) and then set as *plain text* with `$env:OPENAI_API_KEY`:
    ```powershell
    $env:OPENAI_API_KEY = "sk-fake-T3BlbFJi7vpHiKhyYKy8aUT3Blbk"
    ```
   You may also want to put it in your $profile. `$env:OpenAIKey` also works to provide compatibility with other PowerShell modules.

## Quick Start

### Train* a whole bot in one line

Use a bunch of json files to train or "fine tune" a model to make a bot. `Append` allows you to fine-tune an initial model then save that as a new model and train the rest of the files against that.

```powershell
    Get-ChildItem .\sample\totbot*.jsonl | Create-CustomModel -Append
```

*** "train" used in a casual manner, as I am not an ML scientist and you probably aren't either because they don't use PowerShell for these tasks 💔 Anyway, now I can chat with my cat.

![image](https://github.com/potatoqualitee/finetuna/assets/8278033/46ccab85-8cb8-4945-ab1a-09bec63f3718)

### Train a bunch of bots in one line

Drop that append parameter and train a bunch of models with a bunch of jsonl files

```powershell
    Get-ChildItem .\sample\totbot*.jsonl | Create-CustomModel
```

## Usage

1. **Send Files**:
   Use `Send-TuneFile` to upload your training files.

    ```powershell
    Get-ChildItem .\sample\totbot*.jsonl | Send-TuneFile
    ```

2. **Verify File Upload**:
   Use `Get-TuneFile` to make sure your file was uploaded correctly.

    ```powershell
    Get-TuneFile | Select-Object -Last 1
    ```

3. **Start Training**:

   Once your files are ready, start the training job.
    ```powershell
    Get-TuneFile | Out-GridView -Passthru | Start-TuneJob
    ```

## Command Overview

| Command Name       | Description                                        |
|--------------------|----------------------------------------------------|
| Clear-TuneProvider | Clears the OpenAI provider configuration for finetuna |
| Compare-Embedding  | Calculates the similarity between two embedding vectors |
| Create-CustomModel | An alias for New-TuneModel                         |
| Get-Embedding      | Creates an embedding vector for the given text     |
| Get-TuneFile       | Retrieves a list or a specific tuning file         |
| Get-TuneFileContent| Reads the content of a list or specific tuning file|
| Get-TuneJob        | Retrieves a list or details of a specific tuning job|
| Get-TuneJobEvent   | Fetches events for a list or specific tuning job   |
| Get-TuneModel      | Retrieves a list or a specific tuning model        |
| Get-TuneModelDefault| Gets the default model that Invoke-TuneChat uses  |
| Get-TuneProvider   | Retrieves the current OpenAI provider configuration for finetuna |
| Invoke-TuneChat    | Initiates a chat session with a tuning model       |
| Invoke-TunedChat   | Initiates a chat session with any model (alias for Invoke-TuneChat) |
| Measure-TuneToken  | Measures the token usage of the provided text      |
| New-TuneModel      | Creates a new tuning model                         |
| Remove-TuneFile    | Deletes a specific tuning file                     |
| Remove-TuneModel   | Deletes a specific tuning model                    |
| Request-TuneFileReview | Submits a file to Invoke-TuneChat for improvement suggestions |
| Send-TuneFile      | Sends a file for tuning                            |
| Set-TuneModelDefault| Sets the default model that Invoke-TuneChat will use|
| Set-TuneProvider   | Configures the OpenAI or Azure OpenAI service context for finetuna |
| Start-TuneDemo     | Launches the finetuna demo notebook |
| Start-TuneJob      | Starts a new tuning job                            |
| Stop-TuneJob       | Stops a running tuning job                         |
| Test-TuneFile      | Validates tune files before sending to model for training |
| Wait-TuneJob       | Waits for a fine-tuning job to complete            |

## Azure OpenAI Services

finetuna also supports Azure OpenAI services. To use Azure, you need to set up the provider using the `Set-TuneProvider` command:

```powershell
$splat = @{
    Provider   = "Azure"
    ApiKey     = "your-azure-api-key"
    ApiBase    = "https://your-azure-endpoint.openai.azure.com/"
    Deployment = "your-deployment-name"
}
Set-TuneProvider @splat
```

### Azure FAQ

1. **Default Quota**: The default quota for Azure OpenAI services is relatively low. If you're experiencing limitations, consider requesting an increase in your quota through the Azure portal.

2. **Model Compatibility**: If your assistant isn't working as expected, try changing the model in your deployment to ensure your deployment is using a compatible model.

3. **API Versions**: Make sure you're using a compatible API version. Check the Azure documentation for the latest supported versions.

4. **Deployment Name**: When setting up the OpenAI provider for Azure, ensure you're using the correct deployment name. This is different from the model name and is specific to your Azure OpenAI resource.

5. **Region Availability**: Azure OpenAI services may not be available in all Azure regions. Ensure you're using a supported region for your deployment.

## Configuration

### Persisting OpenAI Provider Configuration

You can persist the OpenAI provider configuration to a JSON file using the `Set-TuneProvider` command. This allows you to save the configuration for future sessions:

```powershell
Set-TuneProvider -Provider OpenAI -ApiKey "your-openai-api-key"
```

### Resetting OpenAI Provider Configuration

To reset the OpenAI provider configuration, use the `Clear-TuneProvider` command:

```powershell
Clear-TuneProvider
```

This command will remove the persisted configuration file and reset the configuration to its default state.

## Examples

```powershell
# Upload training files
Get-ChildItem .\sample\totbot*.jsonl | Send-TuneFile

# Start a training job
Get-TuneFile | Out-GridView -Passthru | Start-TuneJob

# Chat with your fine-tuned model
Invoke-TunedChat -Message "Tell me about cats"
```

## Removing Files and Models

### Remove Specific File
Use `Remove-TuneFile` to delete a specific file that you have uploaded.

```powershell
Get-TuneFile | Where-Object Name -eq "sample_file.jsonl" | Remove-TuneFile
```

### Remove Last Uploaded File
```powershell
Get-TuneFile | Select-Object -Last 1 | Remove-TuneFile
```

### Remove Specific Model
Use `Remove-TuneModel` to delete a specific tuning model.

```powershell
Get-TuneModel | Where-Object Name -eq "sample_model" | Remove-TuneModel
```

### Remove All Models
```powershell
Get-TuneModel -Custom | Remove-TuneModel -Confirm:$false
```

Learn more about fine-tuning here: https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/fine-tuning-considerations