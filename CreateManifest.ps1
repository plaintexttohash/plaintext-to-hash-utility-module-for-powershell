if (Get-Module -ListAvailable -Name PSScriptAnalyzer) {
    Invoke-ScriptAnalyzer -Path .\PlaintextToHashUtilityModule.psm1 -Recurse -Severity Information
    Invoke-ScriptAnalyzer -Path .\PlaintextToHashUtilityModule.psm1 -Recurse -Severity Warning
}
else {
    Write-Warning -Message ([String]::Format('The module could not be analyzed.{0}', [Environment]::NewLine))
}

$parameters = @{
    Path              = 'PlaintextToHashUtilityModule.psd1'
    ModuleVersion     = '1.0.0'
    PowerShellVersion = '5.0'
    AliasesToExport   = @('gctd', 'gcca')
    FunctionsToExport = @('Get-ChecksumTextDifference', 'Get-ChecksumCsvAnalysis')
    RootModule        = 'PlaintextToHashUtilityModule.psm1'
    Description       = 'This module contains utilities for handling cryptographic processes, including hashing and calculating a checksum.'
    Author            = 'Ryan E. Anderson'
    Copyright         = 'Copyright (C) 2019 Ryan E. Anderson'
    CompanyName       = 'Plaintext To Hash'
    Tags              = @('PlaintextToHash', 'utility', 'security', 'plaintext', 'hash', 'checksum', 'cryptographic-process', 'cryptography', 'cryptology', 'hashing', 'text-difference', 'encoding', 'decoding')
    LicenseUri        = 'https://github.com/plaintexttohash/plaintext-to-hash-utility-module-for-powershell/blob/master/LICENSE'
    ProjectUri        = 'https://github.com/plaintexttohash/plaintext-to-hash-utility-module-for-powershell'
    IconUri           = 'https://github.com/plaintexttohash/plaintext-to-hash-utility-module-for-powershell/blob/master/media/png/Plaintext-To-Hash-Icon-32-24.png'
    ReleaseNotes      = 'This is the initial release.'
    HelpInfoUri       = 'https://github.com/plaintexttohash/plaintext-to-hash-utility-module-for-powershell/blob/master/README.md'
}

New-ModuleManifest @parameters