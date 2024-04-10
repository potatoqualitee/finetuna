$script:ModuleRoot = $PSScriptRoot
function Import-ModuleFile {
    [CmdletBinding()]
    Param (
        [string]
        $Path
    )

    if ($doDotSource) { . $Path }
    else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}

# Import all internal functions
foreach ($function in (Get-ChildItem "$ModuleRoot\private\" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

$PSDefaultParameterValues["*:ApiKey"] = $env:OpenAIKey
$PSDefaultParameterValues["*:NoTypeInformation"] = $true

Set-Alias -Name Invoke-TunedChat -Value Invoke-TuneChat
Set-Alias -Name Create-CustomModel -Value New-TuneModel

$ErrorActionPreference = "Stop"

$script:modelmapping = @{
    gpt4                = 'cl100k_base'
    gpt35turbo          = 'cl100k_base'
    textembeddingada002 = 'cl100k_base'
    codex               = 'p50k_base'
    textdavinci002      = 'p50k_base'
    textdavinci003      = 'p50k_base'
    davinci             = 'r50k_base'
}

$script:currentmodel = "gpt-3.5-turbo-0125"
$script:baseUrl = "https://api.openai.com/v1"