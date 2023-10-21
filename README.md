# Finetuna: Fine-Tuning OpenAI Models Using PowerShell 7+

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

### Preparing Files for Training

1. **Send Files**:
   Use `Send-TuneFile` to upload your training files.

    ```powershell
    Get-ChildItem .\sample\potato.jsonl | Send-TuneFile | Start-TuneJob
    ```

2. **Verify File Upload**:
   Use `Get-TuneFile` to make sure your file was uploaded correctly.
    ```powershell
    Get-TuneFile
    ```

### Starting and Monitoring Training

1. **Start Training**:
   Once your files are ready, start the training job.
    ```powershell
    Get-TuneFile | Out-GridView -Passthru | Start-TuneJob
    ```

2. **Monitor Training**:
   Use `Get-TuneJob` to monitor the status of your training job.
    ```powershell
    Get-TuneJob -Id your-training-job-id
    ```

### Interacting with Trained Model

1. **Start Chatting**:
   Once your model is trained, you can start a chat session using `Invoke-TuneChat`.
    ```powershell
    Invoke-TuneChat -ModelId your-trained-model-id -Prompt Hello, world!
    ```

