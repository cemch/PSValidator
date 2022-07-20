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
    [OutputType([bool])]
    Param
    (
        # Catalog name to compare against naming standard
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$Name,

        # Regular expression
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false,
            Position=1)]        
        [string]$Regex = '^C_[A-Z]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'
    )

    Begin { }
    Process
    {
        $r = Compare-String -StringValue $Name -Regex $Regex
        return $r
    }
    End { }

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

        # Regular expression
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false,
            Position=1)]        
        [string]$Regex = '^D_[A-Z]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'        
    )

    Begin {}
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
    End {}
     
}

<#
.Synopsis
   This function compares a broker desktop group name against the naming standard
.DESCRIPTION
   
This function make all actions with desktop groups. Valid or invalid. Logs or reports. 
.EXAMPLE
   Confirm-DesktopGroups
#>
function Confirm-DesktopGroups {
[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $WarningLog
)
    # Change Get-Service, put Get-BrokerDesktopGroup
    $dgs = Get-Service | Select-Object Name | Compare-DesktopGroupName
    
    # TODO: CREATE A LOG FOR INVALID NAMES. 

    # TODO: CREATE A REPORT FOR INVALID NAMES.

    return $dgs
}

Confirm-DesktopGroups -WarningLog

