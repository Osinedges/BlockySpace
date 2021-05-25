<#
.SYNOPSIS
   Visualizes disk space.

.DESCRIPTION
   System administration utility designed to generate quickly glanceable pseudo-graphical
   representation of used disk space in a particular directory.
#>

# Stores the character that we print as the visual indicator of the file size. 
# This variable can be overwritten by the user.
$VisualSymbol = '#'

# Stores the width of the visual column in characters.
# The largest file in the directory will always be this number of blocks wide.
$MaxBlocks = 10

# The directory to visualize. The default value "." means current directory,
# or a custom value can be given by the user.
$Directory = "."

function Write-Welcome() {
   "Welcome to Reilly-Disk, this Script will give you a graphical representation of the size of your files"
}

function Write-Menu() {
   "Please select from one of the options below:

   1) Visualise Current Drive Path
   2) Visualise Custom Path
   3) Change visual character (default '#')
   4) Change amount of characters to visualise
   5) Display Script Information
   6) Quit Script
   "
}

function Get-MaxSize($Directory=".") {
   <#
   .SYNOPSIS
      Find the largest file size given a directory path.
   #>
   (Get-ChildItem $Directory |
      ForEach-Object {
         Get-ChildItem -r $_.FullName |
            Measure-Object -property length -sum |
            Select-Object -expand Sum
      }) |
         Measure-Object -Maximum |
         Select-Object -expand Maximum
}

function Get-DirectorySummary($Directory = ".") { 
   # The size of the largest file in the directory.
   # All other files will be some percentage of this,
   # visualized by a partially filled line of visual symbols.
   $MaxSize = Get-MaxSize($Directory)

   # The @ symbol in PowerShell is used to create a hash table.
   # This hash table is used to specify an additional column (field)
   # for the directory summary object.
   $VisualizationColumn = @{
      Label = "Size (Visual)";
      Expression = {
         "[" + 
         "$VisualSymbol" * ($_.Sum * $MaxBlocks / $MaxSize) +
         " " * ($MaxBlocks - ($_.Sum * $MaxBlocks / $MaxSize)) +
         "]"
      }
   }

   Get-ChildItem $Directory | 
      ForEach-Object {
         $f = $_ ; 
         Get-ChildItem -r $_.FullName | 
         Measure-Object -property length -sum | 
         Select-Object @{ Name = "Name"; Expression = {$f} }, Sum, $VisualizationColumn
      }
}

Write-Welcome
while ($true) {
   Write-Menu
   switch(Read-Host -Prompt "Enter number choice:") {
      1 {
         # Clear-Host
         $Directory = "." 
         Get-DirectorySummary($Directory) | Sort-Object sum -Descending
      }

      2 {
         # Clear-Host
         $Directory = Read-Host -Prompt "Enter directory to visualise"
         Get-DirectorySummary($Directory) | Sort-Object sum -Descending
      }

      3 {
         Clear-Host
         $VisualSymbol = Read-Host -Prompt "Enter symbol choice"
      }

      4 {
         Clear-Host
         $MaxBlocks = Read-Host -Prompt "Enter number of symbols you want to visualise with (large differences require larger numbers, default is 10)"
      }

      5 {
         Clear-Host
         Write-Host(
            "This script was created as a way to visualise how much data a directory of files take up in order of size " +
            "and provides a way see in an accurate representation " +
            "the amount of storage it takes up in comparison to its sibling files. " +
            "Script in its entirety was created by Ciaran Reilly and Sviatoslav Chumakov. " +
            "(C) 2019, All Rights Reserved"
         )
      }

      6 {
         Clear-Host
         Write-Host("Thank you for using Reilly-Disk, Script will now terminate.")
         Exit
      }
   }
}