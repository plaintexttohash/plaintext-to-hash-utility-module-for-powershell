$root = Split-Path -Path $PSScriptRoot -Parent

$readmePath = Join-Path -Path $root -ChildPath '\README.md' -Resolve
$licensePath = Join-Path -Path $root -ChildPath '\LICENSE' -Resolve
$modulePath = Join-Path -Path $root -ChildPath '\PlaintextToHashUtilityModule.psm1' -Resolve
$dataPath = Join-Path -Path $root -ChildPath '\PlaintextToHashUtilityModule.psd1' -Resolve
$csvPath = Join-Path -Path $root -ChildPath '\example\Checksums.csv' -Resolve

Import-Module $modulePath

Get-Help Get-ChecksumTextDifference -Full

gctd -FilePath $readmePath -Algorithm md5 -ExpectedChecksum c23e41c02108a168ed15173f37d627f6 | Format-List -Property @{ N = 'TernaryTextDifference'; E = { $_.Item1 } }, @{ N = 'ActualCount'; E = { $_.Item2 } }, @{ N = 'ActualChecksum'; E = { $_.Item3 } }
gctd -FilePath $licensePath -Algorithm md5 -ExpectedChecksum D273D63619C9AEAF15CDAF763D6C4F87 | Format-List -Property @{ N = 'TernaryTextDifference'; E = { $_.Item1 } }, @{ N = 'ActualCount'; E = { $_.Item2 } }, @{ N = 'ActualChecksum'; E = { $_.Item3 } }
gctd -FilePath $modulePath -Algorithm sha384 -ExpectedChecksum 423B541BAB1E43CE70ED7B746AB12EA708726A6FCFD0BF22168DE8EC2E5D90F81B9F78HA57C46924DE3DCCE172C21FBD | Format-List -Property @{ N = 'TernaryTextDifference'; E = { $_.Item1 } }, @{ N = 'ActualCount'; E = { $_.Item2 } }, @{ N = 'ActualChecksum'; E = { $_.Item3 } }
gctd -FilePath $dataPath -Algorithm sha512 -ExpectedChecksum D4AADDE7108611EF75FD68EB5CB533F7B36611A071E173F32BF9DF0A7B65FD076C28C92DA2EC187A510979E258C1ABEC953CE808705F08887D600E6EAFE8EF49 | Format-List -Property @{ N = 'TernaryTextDifference'; E = { $_.Item1 } }, @{ N = 'ActualCount'; E = { $_.Item2 } }, @{ N = 'ActualChecksum'; E = { $_.Item3 } }

$result = gctd -FilePath $readmePath -Algorithm MD5 -ExpectedChecksum c23e40c02109a168ed15173f37d627f6AAAA

$result | Select-Object Item1

Get-Help Get-ChecksumCsvAnalysis -Full

Import-Csv $csvPath | gcca | Format-List -Property FilePath, ProcessIndex, Result