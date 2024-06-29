function Start-TuneDemo {
<#
    .SYNOPSIS
        Launches the finetuna demo notebook in Visual Studio Code or a platform-specific launcher.

    .DESCRIPTION
        The Start-TuneDemo function attempts to launch the 'demo.ipynb' notebook in Visual Studio Code (regular or Insiders edition).
        If Visual Studio Code is not available, it falls back to platform-specific launchers such as Jupyter or the default application associated with .ipynb files.
        If no suitable launcher is found, it displays a warning message advising the user to open the notebook manually.

    .EXAMPLE
        PS C:\> Start-TuneDemo

        Launches the 'demo.ipynb' notebook in Visual Studio Code or a platform-specific launcher.

    .NOTES
        - The function assumes that the 'demo.ipynb' notebook is located in the root directory of the finetuna module.
        - It attempts to launch the notebook using the following methods, in order of preference:
        1. Visual Studio Code (regular edition)
        2. Visual Studio Code Insiders edition
        3. Platform-specific launchers (Jupyter on Windows, 'open' on macOS, 'xdg-open' on Linux)
        - If none of the above methods succeed, it displays a warning message to open the notebook manually.
#>
    [CmdletBinding()]
    param()

    $notebookPath = Join-Path -Path $script:ModuleRoot -ChildPath "demo.ipynb"

    if (-not (Test-Path -Path $notebookPath)) {
        Write-Error "The demo notebook 'demo.ipynb' was not found in the module directory."
        return
    }

    $launched = $false

    # Try launching with Visual Studio Code
    $vscodeCommands = @("code", "code-insiders")
    foreach ($command in $vscodeCommands) {
        $vscodeCheck = Get-Command -Name $command -ErrorAction SilentlyContinue
        if ($vscodeCheck) {
            Start-Process -FilePath $command -ArgumentList "`"$notebookPath`""
            $launched = $true
            break
        }
    }

    if (-not $launched) {
        # Fall back to platform-specific launchers
        if ($IsWindows) {
            Start-Process -FilePath "jupyter" -ArgumentList "notebook `"$notebookPath`""
            $launched = $true
        } elseif ($IsMacOS) {
            Start-Process -FilePath "open" -ArgumentList "-a Jupyter `"$notebookPath`""
            $launched = $true
        } elseif ($IsLinux) {
            Start-Process -FilePath "xdg-open" -ArgumentList "`"$notebookPath`""
            $launched = $true
        }
    }

    if (-not $launched) {
        Write-Warning "Failed to launch the demo notebook. Please open it manually."
    }
}