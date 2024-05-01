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
use it!) to produce a similar experience working
in a language available on **all** operating systems.

# Quick Start

## Installing the Module

1. Head over to the [releases]([TODO](https://github.com/Illbjorn/psmake/releases)) section and grab
the latest PSMake release zip file.
2. Extract this zip file somewhere on your machine.
A path on the `$env:PSModulePath` is likely best.
3. [OPTIONAL]: Add loading of the module file to
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
  foreach ($arg in $args) {
    Write-Host "Hello, ${arg}!"
  }
}
```

> [!NOTE]
> Take note of the `$args` implementation, we'll
> go further into this later.

In your terminal, `cd` to the same directory as your
`make.ps1` file and run: `make sayhello 'John' 'Steve' 'Rob'`.

You should see:
```
PS> make sayhello 'John' 'Steve' 'Rob'
Hello, John!
Hello, Steve!
Hello, Rob!
```

# User-provided PSMake Target Input

As we saw in the example above, if user input is
provided - this is accessible from the `$args`
[automatic variable](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.4).

> [!NOTE]
> `$args` will be of the length, size and type as
> the **actual** provided user input.
>
> For example: `make sometarget 'val1', 'val2'` means
> `$args` will be of type `string[]` holding values
> `val1` and `val2`.

The `make` command uses PowerShell's `ValueFromRemainingArguments`
parameter attribute as a catchall for any "extra"
user-provided arguments. This means all values not
directly provided to a named or positional parameter
will bind to the `AdditionalArguments` parameter.
`AdditionalArguments` is then provided to your
scriptblock, supplied via `target mytarget { myscriptblock }`,
which PowerShell makes available to the scriptblock
itself via the `$args` variable.

# FAQ

## Which operating systems is this supported on?

This is a primary reason for my choosing PowerShell
to implement this functionality: any operating
system Microsoft offers a PowerShell package for!
