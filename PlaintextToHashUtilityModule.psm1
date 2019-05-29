##################################################################################
#                                                                                #
#    Copyright 2019 Ryan E. Anderson                                             #
#                                                                                #
#    Licensed under the Apache License, Version 2.0 (the "License");             #
#    you may not use this file except in compliance with the License.            #
#    You may obtain a copy of the License at                                     #
#                                                                                #
#        http://www.apache.org/licenses/LICENSE-2.0                              #
#                                                                                #
#    Unless required by applicable law or agreed to in writing, software         #
#    distributed under the License is distributed on an "AS IS" BASIS,           #
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#    See the License for the specific language governing permissions and         #
#    limitations under the License.                                              #
#                                                                                #
##################################################################################

#################################################
#                                               #
#    Plaintext To Hash Utility Module v1.0.0    #
#                                               #
#    By Ryan E. Anderson                        #
#                                               #
#    Copyright (C) 2019 Ryan E. Anderson        #
#                                               #
#################################################

Set-StrictMode -Version 2.0

<#
    .SYNOPSIS
    This utility can be used to calculate a text difference.

    .DESCRIPTION
    This utility can be used to calculate a text difference. It writes a tuple with the following entries as output for a pipeline: a ternary string for deciphering a text difference, the actual checksum that was computed against a provided algorithm, and the number of matching characters.

    .PARAMETER FilePath
    Calculations for a checksum and a text difference will be based on this file.

    .PARAMETER Algorithm
    This parameter determines which algorithm will be used to calculate a checksum. The following list contains all possible values for this parameter: md5, sha1, sha256, sha384, and sha512.

    .PARAMETER ExpectedChecksum
    This value is what an actual checksum is expected to be.

    .EXAMPLE
    # Retrieve a tuple containing a ternary text difference.
    Get-ChecksumTextDifference -FilePath .\file-to-check.txt -Algorithm md5 -ExpectedChecksum abcdefghijklmnopqrstuv1234567890

    .EXAMPLE
    # Retrieve a tuple containing a ternary text difference, and pass it along a pipeline to be formatted as a list.
    Get-ChecksumTextDifference -FilePath .\file-to-check.txt -Algorithm md5 -ExpectedChecksum abcdefghijklmnopqrstuv1234567890 | Format-List -Property @{ N = 'TernaryTextDifference'; E = { $_.Item1 } }, @{ N = 'ActualCount'; E = { $_.Item2 } }, @{ N = 'ActualChecksum'; E = { $_.Item3 } }

    .NOTES
    Algorithm names are not case-sensitive.
#>
function Get-ChecksumTextDifference {
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $FilePath,
        [Parameter(Position = 1, Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('md5', 'sha1', 'sha256', 'sha384', 'sha512')]
        [String]
        $Algorithm,
        [Parameter(Position = 2, Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $ExpectedChecksum
    )
    begin {
        $title = 'Plaintext To Hash Utility Module v1.0.0'
        $author = 'By Ryan E. Anderson'
        $copyrightTextLines = @('Copyright (C) 2019 Ryan E. Anderson', 'Copyright (C) 2019 Plaintext To Hash')

        Write-Information -MessageData '#################################################' -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,5}', '#', $title, '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,' + ($title.Length - $author.Length + 5) + '}', '#', $author, '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,' + ($title.Length - $copyrightTextLines[0].Length + 5) + '}', '#', $copyrightTextLines[0], '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,' + ($title.Length - $copyrightTextLines[1].Length + 5) + '}', '#', $copyrightTextLines[1], '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('#################################################{0}', [Environment]::NewLine)) -InformationAction Continue
    }
    process {
        try {
            [int]$actualCount = 0

            $ternaryTextDifferenceString = [String]::Empty

            $actualChecksumObject = Get-FileHash -Path $FilePath -Algorithm $Algorithm -ErrorAction SilentlyContinue | Select-Object Hash

            if ($actualChecksumObject) {
                $actualChecksum = $actualChecksumObject.Hash

                for ($i = 0; $i -lt $ExpectedChecksum.Length; $i++) {
                    if ($i -ge $actualChecksum.Length) {
                        $ternaryTextDifferenceString += '2'

                        continue
                    }

                    if ($ExpectedChecksum[$i] -ieq $actualChecksum[$i]) {
                        $actualCount++

                        $ternaryTextDifferenceString += '1'
                    }
                    else {
                        $ternaryTextDifferenceString += '0'
                    }
                }

                Write-Information -MessageData ([String]::Format('The expected checksum for {0} is {1}.{2}', $FilePath, $ExpectedChecksum, [Environment]::NewLine)) -InformationAction Continue
                Write-Information -MessageData ([String]::Format('The result is as follows: {0}, {1}/{2} (Overflowing results are truncated.).{3}', $ternaryTextDifferenceString, $actualCount, $ExpectedChecksum.Length, [Environment]::NewLine)) -InformationAction Continue

                [Tuple[String, int, String]]$ternaryTextDifferenceTuple = [Tuple]::Create($ternaryTextDifferenceString, $actualCount, $actualChecksum)

                Write-Output $ternaryTextDifferenceTuple
            }
            else {
                Write-Information -MessageData ([String]::Format('The calculation did not succeed. Please, make sure the provided file path is valid.{0}', [Environment]::NewLine)) -InformationAction Continue
            }
        }
        catch {
            Write-Information -MessageData ([String]::Format('An unexpected error that could not be resolved to a certain classification was encountered.{0}', [Environment]::NewLine)) -InformationAction Continue
        }
    }
    end {
        Write-Information -MessageData ([String]::Format('Calculating text differences has completed. Please, review the results.{0}', [Environment]::NewLine)) -InformationAction Continue
    }
}

<#
    .SYNOPSIS
    This utility can be used to analyze checksum data that is in CSV format.

    .DESCRIPTION
    This utility can be used to analyze checksum data that is in CSV format. It reads CSV data that is related to checksums, analyzes it, and writes results as output for a pipeline.

    .PARAMETER ActualChecksum
    This value is the result of performing an additional check against the algorithm that was used to calculate an expected checksum.

    .PARAMETER ExpectedChecksum
    This value is what an actual checksum is expected to be.

    .PARAMETER FilePath
    This optional parameter is used to report a file path, for which a checksum was calculated.

    .EXAMPLE
    # Pass analyses of checksum information in CSV format along a pipeline to be formatted as a list.
    Import-Csv .\example\Checksums.csv | gcca | Format-List -Property Result, ProcessIndex, FilePath

    .NOTES
    Using the Import-Csv cmdlet in tandem with this function is not required, but it is suggested to do so to attain optimal results.
#>
function Get-ChecksumCsvAnalysis {
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $ActualChecksum,
        [Parameter(Position = 1, Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $ExpectedChecksum,
        [Parameter(Position = 2, Mandatory = $false, ValueFromPipelineByPropertyName)]
        [String]
        $FilePath
    )
    begin {
        $title = 'Plaintext To Hash Utility Module v1.0.0'
        $author = 'By Ryan E. Anderson'
        $copyrightTextLines = @('Copyright (C) 2019 Ryan E. Anderson', 'Copyright (C) 2019 Plaintext To Hash')

        Write-Information -MessageData '#################################################' -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,5}', '#', $title, '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,' + ($title.Length - $author.Length + 5) + '}', '#', $author, '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,' + ($title.Length - $copyrightTextLines[0].Length + 5) + '}', '#', $copyrightTextLines[0], '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0,-5}{1}{2,' + ($title.Length - $copyrightTextLines[1].Length + 5) + '}', '#', $copyrightTextLines[1], '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('{0}{1,48}', '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([String]::Format('#################################################{0}', [Environment]::NewLine)) -InformationAction Continue

        [int]$processIndex = -1
    }
    process {
        try {
            $result = New-Object 'PSObject' -Property @{
                FilePath     = $FilePath
                ProcessIndex = ++$processIndex
                Result       = $ActualChecksum -ieq $ExpectedChecksum
            }

            Write-Output $result
        }
        catch {
            Write-Information -MessageData ([String]::Format('An unexpected error that could not be resolved to a certain classification was encountered.{0}', [Environment]::NewLine)) -InformationAction Continue
        }
    }
    end {
        Write-Information -MessageData ([String]::Format('Retrieving analyses of information related to checksums has completed. Please, review the results.{0}', [Environment]::NewLine)) -InformationAction Continue
    }
}

Set-Alias gctd Get-ChecksumTextDifference
Export-ModuleMember -Function Get-ChecksumTextDifference -Alias gctd

Set-Alias gcca Get-ChecksumCsvAnalysis
Export-ModuleMember -Function Get-ChecksumCsvAnalysis -Alias gcca