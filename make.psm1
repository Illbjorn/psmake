#Requires -Version 7.0
# TODO: the version 7.0 requirement is pre-emptive defensive programming, need
# to validate if this is actually a problem for <7.0

###
## Functions
#

function getMakeFilePath {
  Join-Path -Path $PWD.Path -ChildPath 'make.ps1'
}

###
## Exported Commands
#

function make {
  <#
  .SYNOPSIS
  Provides the basic "make" command skeleton.

  .PARAMETER Targets
  The "Make target" from the `make.ps1` file in
  the current directory you wish to call.

  .NOTES
  Author : Anthony Maxwell <am@hades.so>
  #>
  [CmdletBinding(PositionalBinding = $false)] param(
    [Parameter(Mandatory = $false)][string[]]
    $Arguments,
    [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true)][string[]]
    $Targets = @()
  )

  begin {
    # confirm we received a target
    if ($Targets.Count -eq 0) {
      throw 'Make command called with no target.'
    }

    # get path to psmake file
    $makeFilePath = getMakeFilePath

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
    # iterate provided targets
    foreach ($target in $Targets) {
      # confirm our target exists
      if ($target -notin $global:__PSMakeTargets.Keys) {
        throw "Requested target '${target}' not found."
      }

      # confirm our target is a scriptblock
      $scriptBlocks = $global:__PSMakeTargets[$target]
      if ($scriptBlocks -isnot [scriptblock[]]) {
        throw "Requested make target '${target}' is not a valid scriptblock array. Received type: '$($scriptBlocks.GetType())'."
      }

      # iterate scriptblocks
      Write-Host "============ BEGIN: ${target}"
      foreach ($scriptBlock in $scriptBlocks) {
        # execute target, passing in any additional
        # received arguments
        . $scriptBlock $Arguments
        #Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $Arguments
      }
      Write-Host "============ END: ${target}"
    }
  }
}

function target {
  <#
  .SYNOPSIS
  Provides the DSL-like function to replicate a
  Makefile target.

  .PARAMETER Name
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
    [string] $Name,
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [scriptblock[]] $Commands
  )

  begin {
    # create the global make hashtable if needed
    if ($null -eq $global:__PSMakeTargets) {
      $global:__PSMakeTargets = @{}
    }
  }

  process {
    # create the make targets entry
    $global:__PSMakeTargets[$Name] = $Commands
  }
}

###
## Exports
#

Export-ModuleMember -Function make, target
