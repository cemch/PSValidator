<#
.Synopsis
   This function compares a string against a regular expression
.DESCRIPTION
   
This function compares a string against a regular expression and returns a boolean value.
Returns true if the string matches the regular expression. 
.EXAMPLE
   Compare-String -StringValue 'D_APPRED_AZY-PRD' -Regex '[C-D]{1}_[A-Z]{6}_[A-Z]{3}-[A-Z]{3}'
#>
function Compare-String
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([bool])]
    Param
    (
        # String to compare against naming standard
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
        [string]$StringValue,

        # Regular expression
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$false,
            Position=1)]        
        [string]$Regex
    )

    $r = $StringValue -cmatch $Regex
    return $r; 
}

<#
.Synopsis
   This function compares a broker catalog name against the naming standard
.DESCRIPTION
   
This function compares a broker catalog name against the naming standard and returns a boolean value.
Returns true if the string matches the standard. 
.EXAMPLE
   Compare-CatalogName -StringValue 'C_APPRED_AZY-PRD'
#>
function Compare-CatalogName
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Catalog name to compare against naming standard
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$Name,

        # Regular expression for catalog names
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false,
            Position=1)]        
        [string]$Regex = '^C_[A-Z]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'
    )
    
    Process
    {
        $r = Compare-String -StringValue $Name -Regex $Regex
        
        $prop = @{
            'Name'=$Name; 
            'IsValid'=$r; 
        }        
        $obj = New-Object -TypeName psobject -Property $prop        
        
        Write-Verbose $obj
        
        return $obj
    }    
}


<#
.Synopsis
   This function compares a broker desktop group name against the naming standard
.DESCRIPTION
   
This function compares a broker desktop group name against the naming standard and returns a boolean value.
Returns true if the string matches the standard. 
.EXAMPLE
   Compare-DesktopGroupName -StringValue 'D_APPRED_AZY-PRD'
#>
function Compare-DesktopGroupName
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Catalog name to compare against naming standard
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$Name,

        # Regular expression for delivery group names
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false,
            Position=1)]        
        [string]$Regex = '^D_[A-Z]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'        
    )
    
    Process
    {
        $r = Compare-String -StringValue $Name -Regex $Regex
        
        $prop = @{
            'Name'=$Name; 
            'IsValid'=$r; 
        }        
        $obj = New-Object -TypeName psobject -Property $prop        
        
        Write-Verbose $obj
        
        return $obj
    }         
}

<#
.Synopsis
   This function writes log information about invalid names
.DESCRIPTION
   
This function writes log information about invalid names found in Desktop Groups and Catalogs. 
.EXAMPLE
   Write-InvalidNameLog
#>
function Write-InvalidNameLog {
[CmdletBinding()]
param (    
    [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
    [string]
    $Name, 

    [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true, 
        Position=1)]
    [bool]
    $IsValid, 

    [Parameter()]
    [string]
    $Path = (Get-Location), 

    [Parameter()]
    [string]
    $LogName = "InvalidNames"
)

Begin
    {        
        $year = (Get-Date).Year
        $month = (Get-Date).Month
        $day = (Get-date).Day
        $time = (Get-Date).TimeOfDay
        $fullPath = "$Path\$LogName-$year-$month-$day.txt"
        $fullPath

        if((Test-Path -Path $fullPath -PathType Leaf) -eq $false){
            $firstLine = "Time,Name,IsValid"
            $firstLine | Out-File -FilePath $fullPath -Append
        }
        
    }
    Process
    {
        $newLine = "$time,$Name,$IsValid"
        $newLine | Out-File -FilePath $fullPath -Append
    }
}

# write invalid Desktop group names to log file 
# TODO: Change Get-Service for Get-BrokerDesktopGroup
Get-Service | Select-Object Name | Compare-DesktopGroupName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameLog -LogName "Invalid-Desktop-Group-Names"

# write invalid Catalog names to log file 
# TODO: Change Get-Service for Get-BrokerCatalog
Get-Service | Select-Object Name | Compare-CatalogName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameLog -LogName "Invalid-Catalog-Names"
