
function Get-FakeBrokerApplication {

    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Application Name to with the group name is validated
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$ApplicationName,        

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true, 
            Position=1)]
        [string[]]$AssociatedUserFullNames
    )
        
    $fakeApplications = @(); 

    $props1 = @{
        'ApplicationName'=[string]"App1"; 
        'AssociatedUserFullNames'=[string[]]"Group11","Group12"; 
        'UserFilterEnabled'=[bool]$true;
    }        
    $fakeApp1 = New-Object -TypeName psobject -Property $props1
    
    $fakeApplications += $fakeApp1; 

    $props2 = @{
        'ApplicationName'=[string]"App2"; 
        'AssociatedUserFullNames'=[string[]]"Group21","Group22"; 
        'UserFilterEnabled'=[bool]$true;
    }        
    $fakeApp2 = New-Object -TypeName psobject -Property $props2
    
    $fakeApplications += $fakeApp2; 
    
    $props3 = @{
        'ApplicationName'=[string]"App3"; 
        'AssociatedUserFullNames'=[string[]]"SCM_GL_GVA-ConsoleSCCM","Group22"; 
        'UserFilterEnabled'=[bool]$true;
    }        
    $fakeApp3 = New-Object -TypeName psobject -Property $props3
    
    $fakeApplications += $fakeApp3; 

    return $fakeApplications

} 

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
   This function compares a if access policy rule is filtered
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
            $isValid = $false; # if AllowedUsers is Filtered, then IsValid is False. 
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
   Write-InvalidNameToLogFile
#>
function Write-InvalidNameToLogFile {
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


<#
.Synopsis
   This function indicates if application-specific user filter is enabled.
#>
function Compare-FilteredApplication
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Application Name to validate if it is filtered
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$ApplicationName,        

        # UserFilteredEnabled is the property to validate. Must be true. 
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=1)]
        [bool]$UserFilteredEnabled
    )
    
    Process
    { 

        $prop = @{
            'Name'=$ApplicationName; 
            'IsValid'= $UserFilteredEnabled; 
            'Category'="Filtered-Application";
        }        
        $obj = New-Object -TypeName psobject -Property $prop        
        
        Write-Verbose $obj
        
        return $obj
    }    
}

<#
.Synopsis
   This function indicates if a group name complies with the naming standard.
#>
function Compare-ADGroupName
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Group name to compare against naming standard. 
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$GroupName,

        # Regular expression for valid AD group names. Letters and numbers. 
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false,
            Position=1)]        
        [string]$Regex = '^[A-Z]{3}_GL_[A-Z]{3}-[a-zA-Z0-9_]+',

        # Application name owner of the group. 
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=2)]
        [string]$ApplicationName = ""
        
    )
    
    Process
    {
        $r = Compare-String -StringValue $GroupName -Regex $Regex
        
        $prop = @{
            'Name'="$GroupName ($ApplicationName)"; 
            'IsValid'=$r; 
            'Category'="ADGroup-Name";
        }        
        $obj = New-Object -TypeName psobject -Property $prop        
        
        Write-Verbose $obj
        
        return $obj
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

<#
.Synopsis
   This function writes the HTML Report. 
#>
function Write-HtmlReport {

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
    
    $DesktopGroupNames = Get-BrokerDesktopGroup | Select-Object Name | Compare-DesktopGroupName | Where-Object {$_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Invalid Desktop Group Names</h2>"
        
    $CatalogNames = Get-BrokerCatalog | Select-Object Name | Compare-CatalogName | Where-Object {$_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Invalid Catalog Names</h2>"
    
    $FilteredRules = Get-BrokerAccessPolicyRule -property Name,DesktopGroupName,AllowedUsers | Where-Object {$_.AllowedUsers -eq "Filtered"} | ConvertTo-Html -Fragment -PreContent "<h2>Filtered Broker Access Policy Rules</h2>"
    
    $FilteredApplications = Get-brokerApplication -property ApplicationName,UserFilterEnabled | Where-Object {$_.UserFilterEnabled -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Applications with User Filter Disabled</h2>"

    $ApplicationGroupNames = BrokerApplication -property ApplicationName,AssociatedUserFullNames | Compare-ApplicationGroupName | Where-Object {$_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Invalid Application Group names</h2>"
    
    $Header = Get-ReportHeader
    $HtmlReport = ConvertTo-Html -Body "$DesktopGroupNames $CatalogNames $FilteredRules $FilteredApplications $ApplicationGroupNames" -Head $Header -Title "Invalid Names Report" -PostContent "<p>Report created: $(Get-Date)</p>"

    # Write html report to file. 
    $HtmlReport | Out-File -FilePath $reportPath
    
}

<#
.Synopsis
   This function writes all logs for the script. 
#>
function Write-LogFiles {
    param ()
    
    # write invalid Desktop group names to log file     
    Get-BrokerDesktopGroup | Select-Object Name | Compare-DesktopGroupName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameToLogFile

    # write invalid Catalog name to log file     
    Get-BrokerCatalog | Select-Object Name | Compare-CatalogName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameToLogFile

    # write filtered policy rule to log file
    Get-BrokerAccessPolicyRule | Compare-FilteredRule | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameToLogFile

    # Validate if application is user-filtered and write to log file if any. 
    Get-brokerApplication | Compare-FilteredApplication | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameToLogFile

    # Validate application group name against naming standard. 
    Get-BrokerApplication | Compare-ApplicationGroupName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameToLogFile

}


<#
.Synopsis
   This function indicates if application-specific group complies with the naming standard.
#>
function Compare-ApplicationGroupName
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Application Name to with the group name is validated
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [string]$ApplicationName,        

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=1)]
        [string[]]$AssociatedUserFullNames
    )
    
    Process
    {         
       $results = @(); 

        foreach ($groupName in $AssociatedUserFullNames) {            
            $res = Compare-ADGroupName -GroupName $groupName -ApplicationName $ApplicationName
            $results += $res; 
        }

        return $results
    }    
}

Write-LogFiles
Write-HtmlReport

