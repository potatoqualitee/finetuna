
# Finetuna: Fine-Tuning OpenAI Models Using PowerShell 7+

<p align="center">
  <img src="./logo.png" alt="Finetuna Badge"/>
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
