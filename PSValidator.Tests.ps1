$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

BeforeAll {

    function Get-BrokerAccessPolicyRule {
        return "call to Get-BrokerAccessPolicyRule"
    }
    
    function Get-BrokerApplication {
        return "call to Get-BrokerApplication"
    }
   
    function Get-BrokerCatalog {
        return "call to Get-BrokerCatalog"
    }
    
    function Get-BrokerDesktopGroup {
        return "call to Get-BrokerDesktopGroup"
    }
   
    function Get-BrokerMachine {
        return "call to Get-BrokerMachine"
    }
     
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Compare-String Tests" {

    It "Should return True if StringValue matches the Regex" {
        
        Compare-String -StringValue "C_APPBLU" -Regex '^C_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}' | Should -BeTrue
    }

    It "Should return False if StringValue does not match the Regex" {
        Compare-String -StringValue "D_APPBLU" -Regex '^C_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}' | Should -BeFalse
    }
}

Describe "Compare-CatalogName Tests" {

    It "Should return True if Name is a valid catalog name" {
        (Compare-CatalogName -Name "C_APPRED_AZY-PRD" -ScopeName "APPRED").IsValid | Should -BeTrue
    }

    It "Should return False if Name is not a valid catalog name" {
        (Compare-CatalogName -Name "C_ABCDEF_AZY-PRD" -ScopeName "APPRED").IsValid | Should -BeFalse
    }
    
    It "Should return True for an array of valid catalog names using pipeline" {
        $catalogNames = "C_APPRED_AZY-PRD","C_APPRED_AZY-DEV"; 
        $catalogNames | Compare-CatalogName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeTrue }
    }

    It "Should return False for an array of invalid catalog names using pipeline" {
        $catalogNames = "C_APP111_AZY-PRD","C_APP222_AZY-DEV"; 
        $catalogNames | Compare-CatalogName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeFalse }
    }
}

Describe "Compare-DesktopGroupName Tests" {

    It "Should return True if Name is a valid desktop group name" {
        (Compare-DesktopGroupName -Name "D_APPRED_AZY-PRD" -ScopeName "APPBLU").IsValid | Should -BeTrue
    }

    It "Should return False if Name is not a valid desktop group name" {
        (Compare-DesktopGroupName -Name "D_ABCDEF_AZY-PRD" -ScopeName "APPBLU").IsValid | Should -BeFalse
    }

    It "Should return True for an array of valid desktop group names using pipeline" {
        $desktopGroups = "D_APPRED_AZY-PRD","D_APPRED_AZY-DEV"; 
        $desktopGroups | Compare-DesktopGroupName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeTrue }
    }

    It "Should return False for an array of invalid desktop group names using pipeline" {
        $desktopGroups = "D_APP111_AZY-PRD","D_APP222_AZY-DEV"; 
        $desktopGroups | Compare-DesktopGroupName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeFalse }
    }
    
}

Describe "Compare-FilteredRule Tests" {
    BeforeAll{
        $FilteredAccessPolicyRule = [PSCustomObject]@{
            Name = "FilteredAccessPolicyRule1"; 
            DesktopGroupName = "D_APPRED_AZY-PRD"; 
            AllowedUsers = "Filtered"; 
            ScopeName = "APPBLU";            
        }
    }    
    
    It "Should return Not-Applicable for different scope name" {        
        $FilteredAccessPolicyRule | Compare-FilteredRule -ScopeName "APPBLU" | ForEach-Object { $_.ScopeName | Should -BeLike "Not-Applicable" }
    }

    It "Should return the same scope name" {        
        $FilteredAccessPolicyRule | Compare-FilteredRule -ScopeName "APPRED" | ForEach-Object { $_.ScopeName | Should -BeLike "APPRED" }
    }

    It "Should return False for IsValid property" {        
        $FilteredAccessPolicyRule | Compare-FilteredRule -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeFalse }
    }

    It "Should return the same scope name" {        
        $FilteredAccessPolicyRule | Compare-FilteredRule -ScopeName "APPRED" | ForEach-Object { $_.ErrorMessage | Should -BeLike "Access policy rule is filtered, check it please." }
    }
    
}

Describe "Compare-FilteredApplication Tests" {

    BeforeAll{
        $FilteredApplicationDiffScope = [PSCustomObject]@{
            Name = "WSCVDI\GDE\GDE - WIN-PAK"; 
            ApplicationName = "GDE - WIN-PAK"; 
            UserFilterEnabled = $false; 
            ScopeName = "APPBLU";            
        }

        $FilteredApplicationSameScope = [PSCustomObject]@{
            Name = "WSCVDI\GDE\GDE - WIN-PAK"; 
            ApplicationName = "GDE - WIN-PAK"; 
            UserFilterEnabled = $false; 
            ScopeName = "WSCVDI";            
        }
    } 

    It "Should return the same scope name" {        
        $FilteredApplicationSameScope | Compare-FilteredApplication | ForEach-Object { $_.ScopeName | Should -BeLike $FilteredApplicationSameScope.ScopeName }
    }
    
    It "Should return Not-Applicable for different scope name" {        
        $FilteredApplicationDiffScope | Compare-FilteredApplication | ForEach-Object { $_.ScopeName | Should -Be "Not-Applicable" }
    }

    It "Should return an error message" {
        $FilteredApplicationDiffScope | Compare-FilteredApplication | ForEach-Object { $_.ErrorMessage | Should -BeLike "Application filter is not valid. Check it please." } 
    }

}

Describe "Compare-ADGroupName Tests"{

    It " IsValid should be true if group name is correct ... " {
        (Compare-ADGroupName -GroupName "SCM_GL_GVA-ConsoleSCCM" -ApplicationName "GDE - WIN-PAK" -ScopeName "WSCVDI").IsValid | Should -BeTrue
    }

    It " IsValid should be false if group name is incorrect ... " {
        (Compare-ADGroupName -GroupName "SCM_GG_GVA-ConsoleSCCM" -ApplicationName "GDE - WIN-PAK" -ScopeName "WSCVDI").IsValid | Should -BeFalse
    }

    It " IsValid should be false if group name is empty string ... " {
        (Compare-ADGroupName -GroupName "" -ApplicationName "GDE - WIN-PAK" -ScopeName "WSCVDI").IsValid | Should -BeFalse
    }
}

Describe "Compare-MachineState Tests" {

    BeforeAll{
        # Unregistered machine with the same scope name. 
        $UnregisteredMachineSameScope = [PSCustomObject]@{
            MachineName = "GDC\ARH1WIN0001"; 
            RegistrationState = "Unregistered"; 
            CatalogName = "C_APPRED_AZY-PRD"; 
            ScopeName = "APPRED";            
        }

        # Unregistered machine with different scope name.
        $UnregisteredMachineDiffScope = [PSCustomObject]@{
            MachineName = "GDC\ARH1WIN0001"; 
            RegistrationState = "Unregistered"; 
            CatalogName = "C_APPRED_AZY-PRD"; 
            ScopeName = "APPBLU";            
        }

        # Registered machine with the same scope name. 
        $RegisteredMachineSameScope = [PSCustomObject]@{
            MachineName = "GDC\ARH1WIN0001"; 
            RegistrationState = "Registered"; 
            CatalogName = "C_APPRED_AZY-PRD"; 
            ScopeName = "APPRED";            
        }

        # Registered machine with the same scope name. 
        $RegisteredMachineDiffScope = [PSCustomObject]@{
            MachineName = "GDC\ARH1WIN0001"; 
            RegistrationState = "Registered"; 
            CatalogName = "C_APPRED_AZY-PRD"; 
            ScopeName = "APPBLU";            
        }
    } 
       
    It "Should return false for property IsValid" {
        (Compare-MachineState -MachineName $UnregisteredMachineSameScope.MachineName -RegistrationState $UnregisteredMachineSameScope.RegistrationState -CatalogName $UnregisteredMachineSameScope.CatalogName -ScopeName $UnregisteredMachineSameScope.ScopeName).IsValid | Should -BeFalse
    }

    It "Should return true for property IsValid" {
        (Compare-MachineState -MachineName $RegisteredMachineSameScope.MachineName -RegistrationState $RegisteredMachineSameScope.RegistrationState -CatalogName $RegisteredMachineSameScope.CatalogName -ScopeName $RegisteredMachineSameScope.ScopeName).IsValid | Should -BeTrue
    }

    It "Should return same scope name for property ScopeName" {
        (Compare-MachineState -MachineName $UnregisteredMachineSameScope.MachineName -RegistrationState $UnregisteredMachineSameScope.RegistrationState -CatalogName $UnregisteredMachineSameScope.CatalogName -ScopeName $UnregisteredMachineSameScope.ScopeName).ScopeName | Should -Be $UnregisteredMachineSameScope.ScopeName
    }

    It "Should return Not-Applicable for property ScopeName" {
        (Compare-MachineState -MachineName $UnregisteredMachineDiffScope.MachineName -RegistrationState $UnregisteredMachineDiffScope.RegistrationState -CatalogName $UnregisteredMachineDiffScope.CatalogName -ScopeName $UnregisteredMachineDiffScope.ScopeName).ScopeName | Should -Be "Not-Applicable"
    }
    
    It "Should return empty string for property ErrorMessage" {
        (Compare-MachineState -MachineName $RegisteredMachineSameScope.MachineName -RegistrationState $RegisteredMachineSameScope.RegistrationState -CatalogName $RegisteredMachineSameScope.CatalogName -ScopeName $RegisteredMachineSameScope.ScopeName).ErrorMessage | Should -Be ""
    }

    It "Should return error string for property ErrorMessage" {
        (Compare-MachineState -MachineName $UnregisteredMachineDiffScope.MachineName -RegistrationState $UnregisteredMachineDiffScope.RegistrationState -CatalogName $UnregisteredMachineDiffScope.CatalogName -ScopeName $UnregisteredMachineDiffScope.ScopeName).ErrorMessage | Should -Be "Machine is in unregistered state. Check it please."
    }

    It "Should return the same scope name, using pipeline" {
        $UnregisteredMachineSameScope | Compare-MachineState | ForEach-Object { $_.ScopeName | Should -Be $UnregisteredMachineSameScope.ScopeName }        
    }

    It "Should return NotApplicable for different scope name, using pipeline" {
        $UnregisteredMachineDiffScope | Compare-MachineState | ForEach-Object { $_.ScopeName | Should -Be "Not-Applicable" }        
    }
   
    It "Should return True for IsValid property, using pipeline" {
        $RegisteredMachineDiffScope | Compare-MachineState | ForEach-Object { $_.IsValid | Should -BeTrue }        
    }

    It "Should return False for IsValid property, using pipeline" {
        $UnregisteredMachineDiffScope | Compare-MachineState | ForEach-Object { $_.IsValid | Should -BeFalse }        
    }
}

Describe "Get-LogPath Tests" {

    It "Should return a valid full file path" {
        $folder = "c:\test"
        $reportName = "InvalidNames"
        $fileExtension = "txt"
        $scopeName = "APPBLU"
        $date = Get-Date -Format "yyyy-MM-dd" 
        $fullPath = "c:\test\APPBLU-InvalidNames-$date.txt"
        Get-LogPath -Folder $folder -ReportName $reportName -FileExtension $fileExtension -ScopeName $scopeName | Should -Be $fullPath
    }
}

Describe "Write-InvalidNameToLogFile Tests" {

    It "Should write a txt file without Pipeline" {
        
        $filePath = Get-LogPath -Folder (Get-Location) -ReportName "TestReport" -FileExtension "txt" -ScopeName "APPBLU"

        Write-InvalidNameToLogFile -Name "ErrorName" -IsValid $true -Category "Test-Category" -ScopeName "APPBLU" -ErrorMessage "Test error message" -LogPath $filePath
    }

    It "Should create a txt log file using Pipeline" {
        
        $prop = @{
            'Name'="Test-name"; 
            'IsValid'=$false; 
            'Category'="Test-Category";   
            'ScopeName'="APPBLU"; 
            'ErrorMessage'="Test error message";       
        } 

        $obj = New-Object -TypeName psobject -Property $prop  

        $filePath = Get-LogPath -Folder (Get-Location) -ReportName "PipeTestReport" -FileExtension "txt" -ScopeName "APPBLU"

        $obj | Write-InvalidNameToLogFile -LogPath $filePath  
    }
}