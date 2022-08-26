
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
            ValueFromPipeline=$true)]
        [string]$StringValue,

        # Regular expression
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$false)]        
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
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Name,

        # Scope name to validate
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName,
        
        # Regular expression for catalog names
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]        
        [string]$Regex = '^C_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'
    )
    
    Process
    {
        $r = Compare-String -StringValue $Name -Regex $Regex
        
        $errorMessage = ""; 
        if($r -eq $false) {
            $errorMessage = "Catalog name does not comply with the naming standard.";
        }        

        $prop = @{
            'Name'=$Name; 
            'IsValid'=$r; 
            'Category'="Catalog-Name";
            'ScopeName'=$ScopeName; 
            'ErrorMessage'=$errorMessage; 
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
            ValueFromPipelineByPropertyName=$true)]
        [string]$Name,

        [Parameter(
            Mandatory=$true,            
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName, 

        # Regular expression for delivery group names
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]        
        [string]$Regex = '^D_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}_[A-Z]{3}-[PRD|PPD|UAT|QUA|INT|DEV|OAT]{3}\z'
    )
    
    Process
    {
        $r = Compare-String -StringValue $Name -Regex $Regex

        $errorMessage = ""; 
        if($r -eq $false) {
            $errorMessage = "Desktop Group name does not comply with the naming standard.";
        }        

        $prop = @{
            'Name'=$Name; 
            'IsValid'=$r; 
            'Category'="Desktop-Group-Name";   
            'ScopeName'=$ScopeName; 
            'ErrorMessage'=$errorMessage;       
        } 

        $obj = New-Object -TypeName psobject -Property $prop        
        
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
            ValueFromPipelineByPropertyName=$true)]
        [string]$Name,
        
        # Desktop group name
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$DesktopGroupName,

        # Allowd users. Expected values are Filtered or AnyAuthenticated
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$AllowedUsers, 

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName

    )
    
    Process
    {  
        $errorMessage = ""; 
        $isValid = $true; 

        if($AllowedUsers -eq "Filtered"){
            $errorMessage = "Access policy rule is filtered, check it please.";
            $isValid = $false; # if AllowedUsers is Filtered, then IsValid is False. 
        }
        
        # Comparing Scope Name vs. Desktop Group Name
        $Regex = '^D_' + $ScopeName; 
        $r = Compare-String -StringValue $DesktopGroupName -Regex $Regex
        
        if($r -eq $false) {
            $ScopeName= "Not-Applicable";
        }        

        $prop = @{
            'Name'=$Name; 
            'IsValid'= $isValid; 
            'Category'="Filtered-Rule";
            'ScopeName'=$ScopeName; 
            'ErrorMessage'=$errorMessage; 
        }        

        $obj = New-Object -TypeName psobject -Property $prop        
        
        return $obj
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
            ValueFromPipelineByPropertyName=$true)]
        [string]$ApplicationName,        

        # Application Name to validate if it is filtered
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Name,        
        
        # UserFilteredEnabled is the property to validate. Must be true. 
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [bool]$UserFilterEnabled, 

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName
    )
    
    Process
    { 
        $errorMessage = ""; 

        if($UserFilterEnabled -eq $false){
            $errorMessage = "Application filter is not valid. Check it please."
        }
                
        # Comparing full Broker Application Name (Name attribute) vs. Scope Name
        $Regex = '^' + $ScopeName; 
        $r = Compare-String -StringValue $Name -Regex $Regex
        
        if($r -eq $false) {
            $ScopeName= "Not-Applicable";
        }        

        $prop = @{
            'Name'=$ApplicationName; 
            'IsValid'= $UserFilterEnabled; 
            'Category'="Filtered-Application";
            'ScopeName'=$ScopeName; 
            'ErrorMessage'=$errorMessage; 
        }        

        $obj = New-Object -TypeName psobject -Property $prop        
        
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
            ValueFromPipelineByPropertyName=$true)]
        [string]$GroupName,

        # Regular expression for valid AD group names. Letters and numbers. 
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false)]        
        [string]$Regex = '^[A-Z]{3}_GL_[A-Z]{3}-.+',

        # Application name owner of the group. 
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ApplicationName = "", 

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName
    
    )
    
    Process
    {
        # comparing group name against the naming standard. 
        $r = Compare-String -StringValue $GroupName -Regex $Regex
        $errorMessage = ""; 

        if($r -eq $false){
            $errorMessage = "The AD Group Name does not comply with the naming standard."; 
        }

        $prop = @{
            'Name'="$GroupName ($ApplicationName)"; 
            'IsValid'=$r; 
            'Category'="ADGroup-Name";
            'ScopeName'=$ScopeName; 
            'ErrorMessage'=$errorMessage; 
        }  

        # creating the object for logging or reporting the results.       
        $obj = New-Object -TypeName psobject -Property $prop        
        
        return $obj
    }    
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
            ValueFromPipelineByPropertyName=$true)]
        [string]$ApplicationName,        

        # Full Application Name to which the scope is validated
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Name,        

        # Groups associated to the application filter
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string[]]$AssociatedUserFullNames, 

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName
    )
    
    Process
    {

        # Comparing full Broker Application Name (Name attribute) vs. Scope Name
        $Regex = '^' + $ScopeName; 
        $r = Compare-String -StringValue $Name -Regex $Regex
        
        $results = @(); # Array of resultant objects to return. 

        if($r -eq $false) { # Not the same scope
            $ScopeName= "Not-Applicable";
        }   
        
        # comparing each group name against the naming standard for the scope name. 
        foreach ($groupName in $AssociatedUserFullNames) {            
            $res = Compare-ADGroupName -GroupName $groupName -ApplicationName $ApplicationName -ScopeName $ScopeName
            $results += $res; # adding objects to the array. 
        }            
    
        return $results
    }    
}


<#
.Synopsis
   This function indicates if machines are in unregistered state.
#>
function Compare-MachineState
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([psobject])]
    Param
    (
        # Machine name to validate if is unregistered
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$MachineName,        

        # Registration state of the machine
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$RegistrationState,        

        # Catalog name of the machine
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$CatalogName, 

        # Scope name to validate
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName
    )
    
    Process
    {

        # Comparing Catalog name of the machine
        $Regex = $ScopeName; 
        $r = Compare-String -StringValue $CatalogName -Regex $Regex
        
        if($r -eq $false) { # If it does not match the same scope
            $ScopeName= "Not-Applicable";
        }   
        
        # Clean error message
        $errorMessage = ""; 
        $IsValid = $true; 

        if($RegistrationState -eq "Unregistered"){            
            $errorMessage = "Machine is in unregistered state. Check it please."
            $IsValid = $false; 
        }
                
        $prop = @{
            'Name'=$MachineName; 
            'IsValid'= $IsValid; 
            'Category'="Unregistered-Machine";
            'ScopeName'=$ScopeName; 
            'ErrorMessage'=$errorMessage; 
        }        

        $obj = New-Object -TypeName psobject -Property $prop        
        
        return $obj
        
    }    
}


function Get-LogPath {

    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    param (
               
        [Parameter(
            Mandatory=$true
        )]
        [string]
        $Folder,

        [Parameter(
            Mandatory=$true
        )]
        [string]
        $ReportName, 

        [Parameter(
            Mandatory=$true
        )]
        [string]
        $FileExtension,

        [Parameter(
            Mandatory=$true
        )]
        [string]
        $ScopeName
    )

    $date = Get-Date -Format "yyyy-MM-dd"              

    $fullPath = "$Folder\$ScopeName-$ReportName-$date.$FileExtension"
    
    return $fullPath

}


<#
.Synopsis
   This function returns css style for the html report.
#>
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
   This function writes all logs for the script. 
#>
function Write-LogFiles {
    
    param (

        [Parameter(
            Mandatory=$true
        )]
        [string]
        $ScopeName, 
        
        [Parameter(
            Mandatory=$true
        )]
        [string]
        $LogPath
        
    )    
    
    # write invalid Desktop group names to log file     
    Get-BrokerDesktopGroup -ScopeName $ScopeName | Select-Object -Property Name | Compare-DesktopGroupName -ScopeName $ScopeName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameToLogFile -LogPath $LogPath

    # write invalid Catalog name to log file     
    Get-BrokerCatalog -ScopeName $ScopeName | Select-Object -Property Name | Compare-CatalogName -ScopeName $ScopeName | Where-Object {$_.IsValid -eq $false} | Write-InvalidNameToLogFile -LogPath $LogPath
    
    # write filtered policy rule to log file
    Get-BrokerAccessPolicyRule | Select-Object -Property Name,DesktopGroupName,AllowedUsers,@{n='ScopeName';e={$ScopeName}} | Compare-FilteredRule | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | Write-InvalidNameToLogFile -LogPath $LogPath

    # Validate if application is user-filtered and write to log file if any. 
    Get-BrokerApplication | Select-Object -Property ApplicationName,Name,UserFilterEnabled,@{n='ScopeName';e={$ScopeName}} | Compare-FilteredApplication | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | Write-InvalidNameToLogFile -LogPath $LogPath

    # Validate application group name against naming standard. 
    Get-BrokerApplication | Select-Object -Property ApplicationName,Name,AssociatedUserFullNames,@{n='ScopeName';e={$ScopeName}} | Compare-ApplicationGroupName | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | Write-InvalidNameToLogFile -LogPath $LogPath

    # Validate machines that are in unregistered state
    Get-BrokerMachine | Select-Object -Property MachineName,RegistrationState,CatalogName,@{n='ScopeName';e={$ScopeName}} | Compare-MachineState | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | Write-InvalidNameToLogFile -LogPath $LogPath
}


<#
.Synopsis
   This function writes the HTML Report. 
#>
function Write-HtmlReport {

    param (

        [Parameter(
            Mandatory=$true
        )]
        [string]
        $ScopeName, 
        
        [Parameter(
            Mandatory=$true
        )]
        [string]
        $ReportPath 
    )
        
    #Creating each section of the html report.

    $DesktopGroupNames = Get-BrokerDesktopGroup -ScopeName $ScopeName | Select-Object -Property Name, @{n='ScopeName';e={$ScopeName}} | Compare-DesktopGroupName | Where-Object {$_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Invalid Desktop Group Names for scope $ScopeName</h2>"
        
    $CatalogNames = Get-BrokerCatalog -ScopeName $ScopeName | Select-Object -Property Name, @{n='ScopeName';e={$ScopeName}} | Compare-CatalogName | Where-Object {$_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Invalid Catalog Names for scope $ScopeName</h2>"
    
    $FilteredRules = Get-BrokerAccessPolicyRule | Select-Object -Property Name,DesktopGroupName,AllowedUsers, @{n='ScopeName';e={$ScopeName}} | Compare-FilteredRule | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Filtered Broker Access Policy Rules for scope $ScopeName</h2>"
        
    $FilteredApplications = Get-brokerApplication | Select-Object -Property ApplicationName,Name,UserFilterEnabled, @{n='ScopeName';e={$ScopeName}} | Compare-FilteredApplication | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Applications with User Filter Disabled for scope $ScopeName</h2>"

    $ApplicationGroupNames = Get-brokerApplication | Select-Object -Property ApplicationName,Name,AssociatedUserFullNames, @{n='ScopeName';e={$ScopeName}} | Compare-ApplicationGroupName | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Invalid Application Group names for scope $ScopeName</h2>"
    
    $UnregisteredMachines = Get-brokerApplication | Select-Object -Property MachineName,RegistrationState,CatalogName,@{n='ScopeName';e={$ScopeName}} | Compare-MachineState | Where-Object {$_.ScopeName -eq $ScopeName -and $_.IsValid -eq $false} | ConvertTo-Html -Fragment -PreContent "<h2>Unregistered Machines for scope $ScopeName</h2>"
    
    $Header = Get-ReportHeader

    # Generating html report. 
    $HtmlReport = ConvertTo-Html -Body "$DesktopGroupNames $CatalogNames $FilteredRules $FilteredApplications $ApplicationGroupNames $UnregisteredMachines" -Head $Header -Title "Report of issues for scope $ScopeName" -PostContent "<p>Report created: $(Get-Date)</p>"

    # Write html report to file. 
    $HtmlReport | Out-File -FilePath $ReportPath
    
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
                ValueFromPipelineByPropertyName=$true)]
        [string]$Name, 
    
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true)]
        [bool]$IsValid, 
    
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true)]
        [string]$Category, 
    
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true)]
        [string]$ScopeName, 
        
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true)]
        [string]$ErrorMessage, 
        
        [Parameter(
            Mandatory=$true,            
            ValueFromPipelineByPropertyName=$true)]
        [string]$LogPath
    )
    
    Begin
        {                      
            $time = (Get-Date).TimeOfDay
                
            if((Test-Path -Path $LogPath -PathType Leaf) -eq $false){
                $firstLine = "Time,Name,IsValid,Category,Scope,ErrorMessage"
                $firstLine | Out-File -FilePath $LogPath -Append
            }            
        }
        Process
        {
            $newLine = "$time,$Name,$IsValid,$Category,$ScopeName,$ErrorMessage"
            $newLine | Out-File -FilePath $LogPath -Append
        }
    }
    
function Start-Validation {

    param (

        [Parameter(
            Mandatory=$true
        )]
        [string] $ScopeName, 
        
        [Parameter()]
        [string] $FolderPath = (Get-Location),     

        [Parameter()]
        [string] $ReportName = "InvalidNames"

    )
        
    $logPath = Get-LogPath -Folder $FolderPath -ReportName $ReportName -FileExtension "txt" -ScopeName $ScopeName

    # Write to csv file by scope. 
    Write-LogFiles -ScopeName $ScopeName -LogPath $logPath

    $reportPath = Get-LogPath -Folder $FolderPath -ReportName $ReportName -FileExtension "html" -ScopeName $ScopeName

    # write to html report file by scope. 
    Write-HtmlReport -ScopeName $ScopeName -ReportPath $reportPath

}

# Adding Citrix cmdlets 
# Add-PSSnapIn Citrix.*

# # Indicating delivery controllers IP
# Get-BrokerSite -AdminAddres 127...

# # Start validation job by scope. 
# Start-Validation -ScopeName "APPBLU"
