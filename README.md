# finetuna: Fine-tuned PowerShell module to Fine-Tune OpenAI Models

<p align="center">
  <img src="./logo.png"/>
</p>

## Introduction

finetuna is designed to simplify the fine-tuning of OpenAI models. Import data from CSV and PDF files, automatically converting them to the required JSONL format.

Train your models and interact with them—all through PowerShell.

## Prerequisites

- PowerShell 7 or above

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
---

## Quick Start

### Train* a whole bot in one line

Use a bunch of json files to train or "fine tune" a model to make a bot. `Append` allows you to fine-tune an initial model then save that as a new model and train the rest of the files against that.

```powershell
    Get-ChildItem .\sample\totbot*.jsonl | Create-CustomModel -Append
```

*** "train" used in a casual manner, as I am not an ML scientist and you probably aren't either because they don't use PowerShell for these tasks 💔

### Train a bunch of bots in one line

Drop that append parameter and train a bunch of models with a bunch of jsonl files

```powershell
    Get-ChildItem .\sample\totbot*.jsonl | Create-CustomModel
```
| Command Name       | Description                                        |
|--------------------|----------------------------------------------------|
| Create-CustomModel | An alias for New-TuneModel                         |
| Invoke-TunedChat   | Initiates a chat session with any model            |
| Get-TuneFile       | Retrieves a list or a specific tuning file         |
| Get-TuneFileContent| Reads the content of a list or specific tuning file|
| Get-TuneJob        | Retrieves a list or details of a specific tuning job|
| Get-TuneJobEvent   | Fetches events for a list or specific tuning job   |
| Get-TuneModel      | Retrieves a list or a specific tuning model        |
| Invoke-TuneChat    | Initiates a chat session with a tuning model       |
| New-TuneModel      | Creates a new tuning model                         |
| Remove-TuneFile    | Deletes a specific tuning file                     |
| Remove-TuneModel   | Deletes a specific tuning model                    |
| Send-TuneFile      | Sends a file for tuning                            |
| Start-TuneJob      | Starts a new tuning job                            |
| Stop-TuneJob       | Stops a running tuning job                         |

### Some training commands

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


1. **Start Training**:

   Once your files are ready, start the training job.
    ```powershell
    Get-TuneFile | Out-GridView -Passthru | Start-TuneJob
    ```

### Removing Files and Models

#### Remove Specific File
Use `Remove-TuneFile` to delete a specific file that you have uploaded. Supports piping from `Get-TuneFile`.

```powershell
Get-TuneFile | Where-Object Name -eq "sample_file.jsonl" | Remove-TuneFile
```

#### Remove Last Uploaded File
Use `Remove-TuneFile` to delete the last file that was uploaded. This also pipes from `Get-TuneFile`.

```powershell
Get-TuneFile | Select-Object -Last 1 | Remove-TuneFile
```

### Removing Models

#### Remove Specific Model
Use `Remove-TuneModel` to delete a specific tuning model. Supports piping from `Get-TuneModel`.

```powershell
Get-TuneModel | Where-Object Name -eq "sample_model" | Remove-TuneModel
```

#### Remove All Models
Use `Remove-TuneModel` to delete all models. Be careful with this one!

```powershell
Get-TuneModel -Custom | Remove-TuneModel -Confirm:$false
```

Sorry these docs suck, I gotta work on a presentation so I'll fix them later.