Import-Module Terminal-Icons
function Echo-WithColor {
  <#
    .SYNOPSIS
    Echo a message with color
  #>
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage="Enter one resource type")]
    [string] $_msg,
    [Parameter(Mandatory = $false, HelpMessage="Enter one color. The default is Green")]
    [string] $_color
  )
  if ($_color -eq "") {
      $_color = "Green"
  }
  Write-Host $_msg -ForegroundColor $_color
}
Set-Alias cecho Echo-WithColor

function Get-LatestFiles {
  <#
    .SYNOPSIS
    Get the latest files up to N
  #>
    param(
        [Parameter(HelpMessage="Enter a number for max result")]
        [int] $MaxNumberOfResults,
        [Alias("r")]
        [switch] $Recurse
        )
    process {
      if ($MaxNumberOfResults -le 0) {
        $MaxNumberOfResults = 10
      }
      if ($Recurse) {
        Get-ChildItem -Recurse | Sort-Object -Property LastWriteTime -Descending | Select-Object -First $MaxNumberOfResults | select Mode, LastWriteTime, FullName
      } else {
        Get-ChildItem | Sort-Object -Property LastWriteTime -Descending | Select-Object -First $MaxNumberOfResults | select Mode, LastWriteTime, FullName
      }
    }
}
Set-Alias gf Get-LatestFiles

function New-NvimFile {
  <#
    .SYNOPSIS
    Create a memo file with current date.
  #>
  param (
        [string]$MyArg = "temp"
        )
    $date = Get-Date -Format "yyyyMMdd"
    nvim "$MyArg-$date.md"
}

Set-Alias nn New-NvimFile


function Get-Directory {
  <#
    .SYNOPSIS
    Get all subdirectories
  #>
  Get-ChildItem -Attribute Directory
}

Set-Alias gd Get-Directory
Set-Alias n nvim
$_init = "C:\Users\ilmojung\AppData\Local\nvim\init.lua"
function edn {
  nvim $_init
}

function cdn {
  cd "C:\Users\ilmojung\AppData\Local\nvim\"
}

function cdm {
  cd ~\memo
}

function edt {
  nvim ~\toolbox.ps1
}

function Open-With-Neovim {
    $file = fzf
    if ($file) {
        nvim $file
    }
}
Set-Alias own Open-With-Neovim

function Fzf-With-Preview {
    $file = fzf --preview 'bat --style=numbers --color=always {}' --preview-window=right:60%
    if ($file) {
        nvim $file
    }
}
Set-Alias ff Fzf-With-Preview


function Search-Content {
    param (
        [string]$searchTerm
    )
    rg --files-with-matches --no-messages $searchTerm | fzf
}
Set-Alias rgn Search-Content

function Source-Toolbox {
    . ~\toolbox.ps1
}
Set-Alias st Source-Toolbox

