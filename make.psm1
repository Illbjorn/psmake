#Requires -Version 7.0
# TODO: the version 7.0 requirement is pre-emptive
# defensive programming, need to validate if this
# is actually a problem for <7.0

###
## Vars
#

# define a path to a 'make.ps1' file in the current
# working directory
#
# this is used when a make command is called to dot
# source the make ps1 file in the current working
# directory
#
# we use Join-Path here to prevent path separator
# conflicts on different OS platforms
$makeFilePath =
  Join-Path -Path $PWD.Path -ChildPath 'make.ps1'

###
## Exported Commands
#

function make {
  <#
  .SYNOPSIS
  Provides the basic "make" command skeleton.

  .PARAMETER Target
  The "Make target" from the `make.ps1` file in
  the current directory you wish to call.

  .NOTES
  Author : Anthony Maxwell <am@hades.so>
  #>
  [CmdletBinding(PositionalBinding = $false)]
  param(
    [Parameter(
      Position = 0,
      Mandatory = $false)]
    [string] $Target = '',
    [Parameter(
      Mandatory = $false)]
    [string] $File = $makeFilePath,
    [Parameter(
      Mandatory = $false,
      ValueFromRemainingArguments = $true)]
    [string[]] $AdditionalArgs
  )

  begin {
    # confirm we received a target
    if ($Target -eq '') {
      throw 'Make command called with no target.'
    }

    # check if the psmake file exists
    if (!(Test-Path -Path $makeFilePath -PathType Leaf)) {
      throw 'No psmake file found.'
    }

    # wipe make target table
    $global:__PSMakeTargets = $null

    # dot source psmake file
    . $makeFilePath

    # confirm the sourced psmake file exported targets
    if ($null -eq $global:__PSMakeTargets) {
      throw 'PSMake file was found, but it contained no exported targets.'
    }
  }

  process {
    # confirm our target exists
    if ($Target -notin $global:__PSMakeTargets.Keys) {
      throw "Requested target '${Target}' not found."
    }

    # confirm our target is a scriptblock
    $exec = $global:__PSMakeTargets[$Target]
    if ($exec -isnot [scriptblock]) {
      throw "Requested make target '${Target}' is not a valid scriptblock. Received type: '$($exec.GetType())'."
    }

    # execute target, passing in any additional
    # received arguments
    Write-Host "============ BEGIN: ${Target}"
    Invoke-Command -ScriptBlock $exec -ArgumentList $AdditionalArgs
    Write-Host "============ END: ${Target}"
  }
}

function target {
  <#
  .SYNOPSIS
  Provides the DSL-like function to replicate a
  Makefile target.

  .PARAMETER Target
  The desired name of the "Make target".

  .PARAMETER Command
  The scriptblock to execute when the above target
  is called.

  .EXAMPLE
  "Makefile" `make.ps1`:
  ```
  target 'sayHello' { Write-Host "Hello!" }
  ```

  From an interactive shell:
  ```
  PS> make sayHello
  Hello!
  ```

  .NOTES
  Author : Anthony Maxwell <am@hades.so>
  #>
  [CmdletBinding()]
  Param(
    [Parameter(Position = 0)]
    [string] $Target,
    [Parameter(Position = 1)]
    [scriptblock] $Command
  )

  begin {
    # create the global make hashtable if needed
    if ($null -eq $global:__PSMakeTargets) {
      $global:__PSMakeTargets = @{}
    }
  }

  process {
    # create the make target entry
    $global:__PSMakeTargets[$Target] = $Command
  }
}

###
## Exports
#

Export-ModuleMember -Function make, target
