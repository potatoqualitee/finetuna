$script:ModuleRoot = $PSScriptRoot
$script:ValidModels = @("gpt-3.5-turbo-0125", "gpt-3.5-turbo-1106", "gpt-3.5-turbo-0613", "babbage-002", "davinci-002", "gpt-4-0613", "gpt-4o-2024-05-13")

if (-not (Get-Module PSOpenAI)) {
    $null = Import-Module PSOpenAI
}
# Get PSOpenAI's private functions
$modulepath = Get-Module -Name PSOpenAI -ListAvailable | Select-Object -First 1
$privatedir = Join-Path -Path $modulepath.ModuleBase -ChildPath Private
function ValidateModelName {
    param([string]$ModelName)
    if ($ModelName -notin $script:ValidModels -and -not $ModelName.StartsWith("ft:")) {
        throw "Invalid model name. Must be one of the predefined models or start with 'ft:' for fine-tuned models."
    }
}
function Import-ModuleFile {
    [CmdletBinding()]
    Param (
        [string]
        $Path
    )

    if ($doDotSource) { . $Path }
    else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}

foreach ($file in (Get-ChildItem -Path $privatedir -Filter *.ps1)) {
    . Import-ModuleFile -Path $file.FullName
}

# Import all internal functions
foreach ($function in (Get-ChildItem "$ModuleRoot\private\" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

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

$script:currentmodel = "gpt-4o"

# Add these lines after the existing content in the finetuna PSM1

$script:configdir = switch ($PSVersionTable.Platform) {
    "Unix" { "$home/.config/finetuna" }
    default { "$env:APPDATA\finetuna" }
}

if (-not (Test-Path -Path $script:configdir)) {
    $null = New-Item -Path $script:configdir -ItemType Directory -Force
}

$configFile = Join-Path -Path $script:configdir -ChildPath config.json

$apiKey = (Get-OpenAIContext).ApiKey

if (-not $apiKey -and (Test-Path -Path $configFile)) {
    $persisted = Get-Content -Path $configFile -Raw | ConvertFrom-Json
    $splat = @{}
    if ($persisted.ApiKey) { $splat.ApiKey = $persisted.ApiKey }
    if ($persisted.ApiBase) { $splat.ApiBase = $persisted.ApiBase }
    if ($persisted.Deployment) { $splat.Deployment = $persisted.Deployment }
    if ($persisted.ApiType) { $splat.ApiType = $persisted.ApiType }
    if ($persisted.ApiVersion) { $splat.ApiVersion = $persisted.ApiVersion }
    if ($persisted.AuthType) { $splat.AuthType = $persisted.AuthType }
    if ($persisted.Organization) { $splat.Organization = $persisted.Organization }
    $null = Set-TuneProvider @splat
}