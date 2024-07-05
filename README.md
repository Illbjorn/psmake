# Overview

Welcome to PSMake! The very, very simple "Make"-like
implementation for PowerShell (7.0+) users.

# Why "PSMake"?

The traditional Makefile experience on Linux/Mac
operating systems is super convenient. Being able
to quickly define short, memorable targets to invoke
frequently referenced commands is a quite useful
boon to productivity.

The problem in this equation is Make on Windows.
While there are ways to get Make working on Windows,
they're not well defined, instructions aren't stellar,
and it's a process fraught with edge-case error conditions
that will likely not be documented.

PSMake is something I created (because I want to
use it!) to produce a similar experience in a
language available on **all** major operating systems.

# Quick Start

## Installing the Module

1. Head over to the [releases](https://github.com/Illbjorn/psmake/releases) section and grab
the latest PSMake release module (.psm1) file.
A path on the `$env:PSModulePath` is likely best.
2. [OPTIONAL]: Add loading of the module file to
your PowerShell profile (`$PROFILE`) like:
```powershell
# If you extracted the module file on
# $env:PSModulePath
Import-Module 'make'
# If you extracted the module file to an arbitrary
# location
Import-Module 'C:\Path\To\Make.psm1'
```

At this point "PSMake" is installed!

## Creating a Working Example

Create a `make.ps1` file with the following contents:
```powershell
target 'sayhello' {
  [CmdletBinding()] param(
    [Parameter(ValueFromRemainingArguments = $true)] [string[]]
    $Names
  )
  foreach ($name in $Names) {
    Write-Host "Hello, ${name}!"
  }
}
```

> [!NOTE]
> Parameters defined in a `param()` statement are **_positionally_** bound.

In your terminal, `cd` to the same directory as your
`make.ps1` file and run: `make sayhello -Arguments 'John' 'Steve' 'Rob'`.

You should see:
```
PS> make sayhello -Arguments 'John' 'Steve' 'Rob'
Hello, John!
Hello, Steve!
Hello, Rob!
```

# FAQ

## Which operating systems is this supported on?

This is a primary reason for my choosing PowerShell
to implement this functionality: any operating
system Microsoft offers a PowerShell package for!

## Are targets case sensitive?

No! PowerShell is not a case-sensitive language,
your targets can be defined as `mEmEcAsE` if you
so desired and that would work if invoked like:
`make memecase`!
