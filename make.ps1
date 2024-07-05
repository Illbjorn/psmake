<#
.SYNOPSIS
`make.ps1` is the PSMake file actually used for
development of this module.

.NOTES
Author : Anthony Maxwell <am@hades.so>
#>

###
## Functions
#

# produces an operating system path separator
# independent path to the .VERSION file
function dotVersionFilePath {
  # define path segments to .VERSION file
  $params = @{
    Path                = $PSScriptRoot
    ChildPath           = '.github'
    AdditionalChildPath = '.VERSION'
  }

  # assemble & output to pipeline
  Join-Path @params
}

# produces a sanitized (MAJOR.MINOR.PATCH) semantic
# version string from the .VERSION file at the provided
# path
function getVersionFromFile([string] $path) {
  # confirm our provided file exists
  if (!(Test-Path -Path $verFilePath -PathType Leaf)) {
    throw "Provided file path does not exist or is not a file: ${path}"
  }

  # get file content
  $content = Get-Content -Path $verFilePath -Raw

  # produce version string
  if ($content -match '^\s*(\d+\.\d+\.\d+)') {
    $matches[1]
  } else {
    throw 'Provided .VERSION file contains a missing or invalid semantic version string.'
  }
}

# increments the specified semantic version segment
# of a provided version string
function incrementVersionSegment([string] $version, [string] $segment) {
  # disassemble version string segments
  [int] $major,
  [int] $minor,
  [int] $patch = $version -split '\.'

  # bump appropriate segment
  switch ($segment) {
    'major' { $major++; $minor = 0; $patch = 0 }
    'minor' { $minor++; $patch = 0 }
    'patch' { $patch++ }
    default { throw "Received unexpected version string segment: ${segment}" }
  }

  # reassemble and output
  "${major}.${minor}.${patch}"
}

# writes a provided semantic version string to the
# provided file path
function setFileVersionString([string] $path, [string] $version) {
  # write the version string to file
  Set-Content -Path $path -Value $version | Out-Null
}

###
## PSMake Target Functionality
#

[scriptblock] $bump = {
  [CmdletBinding()] param(
    [string] $VersionSegment
  )
  # get path to .VERSION file
  $verFilePath = dotVersionFilePath

  # get version string from the .VERSION file
  $ver = getVersionFromFile $verFilePath

  # increment the requested segment
  $newVer = incrementVersionSegment $ver $VersionSegment

  # write the version back to file
  setFileVersionString $verFilePath $newVer

  Write-Host "Bumped Version: ${ver} -> ${newVer}"
}

###
## PSMake Targets
#

# Bump accepts an input of 'major', 'minor' or
# 'patch' and increments that segment of the
# semantic version string in: .github/.VERSION
target 'bump' $bump
