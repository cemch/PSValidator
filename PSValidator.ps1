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
        [string]$Regex = '^C_[APPYEL|APPGRE|LAPPBLU|WSCEMS|WSCVDI]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'
    )
    
    Process
    {
        $r = Compare-String -StringValue $Name -Regex $Regex
        
        $prop = @{
            'Name'=$Name; 
            'IsValid'=$r; 
            'Category'="Catalog-Name";
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
        [string]$Regex = '^D_[APPYEL|APPGRE|LAPPBLU|WSCEMS|WSCVDI]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'
    )
    
    Process
    {
        $r = Compare-String -StringValue $Name -Regex $Regex
        
        $prop = @{
            'Name'=$Name; 
            'IsValid'=$r; 
            'Category'="Desktop-Group-Name";
        }        
        $obj = New-Object -TypeName psobject -Property $prop        
        
        Write-Verbose $obj
        
        return $obj
    }         
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
function Compare-FilteredRule
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Broker Access Policy Rule Name to validate if it is filtered
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$Name,
        
        # Desktop group name
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=1)]
        [string]$DesktopGroupName,

        # Allowd users. Expected values are Filtered or AnyAuthenticated
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=2)]
        [string]$AllowedUsers
    )
    
    Process
    {  
        $isValid = $true; 
        if($AllowedUsers -eq "Filtered"){
            $isValid = $false; 
        }

        $prop = @{
            'Name'=$Name; 
            'IsValid'= $isValid; 
            'Category'="Filtered-Rule";
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

    [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true, 
        Position=2)]
    [string]
    $Category, 

    [Parameter()]
    [string]
    $Path = (Get-Location), 

    [Parameter()]
    [string]
    $LogName = "InvalidNames"
)

Begin
    {      
        $date = Get-Date -Format "yyyy-MM-dd"          
        $time = (Get-Date).TimeOfDay

        $fullPath = "$Path\$LogName-$date.txt"
        $fullPath

        if((Test-Path -Path $fullPath -PathType Leaf) -eq $false){
            $firstLine = "Time,Name,IsValid,Category"
            $firstLine | Out-File -FilePath $fullPath -Append
        }
        
    }
    Process
    {
        $newLine = "$time,$Name,$IsValid,$Category"
        $newLine | Out-File -FilePath $fullPath -Append
    }
}

function Get-ReportHeader {
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param()
$header = @"
<style>
    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }
    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }

        #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }

</style>
"@

return $header
}

function Write-InvalidNameReport {

    param (

        [Parameter()]
        [string]
        $Path = (Get-Location),     

        [Parameter()]
        [string]
        $ReportName = "InvalidNames"
    )
    
    # Path for html report
    $date = Get-Date -Format "yyyy-MM-dd"              
    $reportPath = "$Path\$ReportName-$date.html"    
    $reportPath
    
    $DesktopGroupNames = Get-BrokerDesktopGroup | Select-Object Name | Compare-DesktopGroupName | Where-Object {$_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Desktop Group Names</h2>"
        
    $CatalogNames = Get-BrokerCatalog | Select-Object Name | Compare-CatalogName | Where-Object {$_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Catalog Names</h2>"
    
    $FilteredRules = Get-BrokerAccessPolicyRule -property Name,DesktopGroupName,AllowedUsers | Where-Object {$_.AllowedUsers -eq "Filtered"} | ConvertTo-Html -Fragment -PreContent "<h2>Filtered Broker Access Policy Rules</h2>"
    
    $Header = Get-ReportHeader
    $HtmlReport = ConvertTo-Html -Body "$DesktopGroupNames $CatalogNames $FilteredRules" -Head $Header -Title "Invalid Names Report" -PostContent "<p>Report created: $(Get-Date)</p>"

    # Write html report to file. 
    $HtmlReport | Out-File -FilePath $reportPath
    
}

function Write-InvalidNameLogs {
    param ()
    
    # write invalid Desktop group names to log file     
    Get-BrokerDesktopGroup | Select-Object Name | Compare-DesktopGroupName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameLog

    # write invalid Catalog names to log file     
    Get-BrokerCatalog | Select-Object Name | Compare-CatalogName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameLog

    # write filtered policy rules to log file
    Get-BrokerAccessPolicyRule | Compare-FilteredRule | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameLog

}

Write-InvalidNameLogs
Write-InvalidNameReport

