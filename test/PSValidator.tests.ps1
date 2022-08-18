$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

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
}

Describe "Compare-ApplicationGroupName Tests" {

    BeforeAll{
        # Application name with the same scope name. 
        $ApplicationGroupNameSameScope = [PSCustomObject]@{
            Name = "WSCVDI\GDE\GDE - WIN-PAK"; 
            ApplicationName = "GDE - WIN-PAK"; 
            AssociatedUserFullNames = "SCM_GL_GVA-ConsoleSCCM","GDE_GL_GVA- WIN-PAK"; 
            ScopeName = "WSCVDI";            
        }

        # Application name with different scope name.
        $ApplicationGroupNameDiffScope = [PSCustomObject]@{
            Name = "WSCVDI\GDE\GDE - WIN-PAK"; 
            ApplicationName = "GDE - WIN-PAK"; 
            AssociatedUserFullNames = "SCM_GL_GVA-ConsoleSCCM","GDE_GL_GVA- WIN-PAK"; 
            ScopeName = "APPBLU";            
        }

        # An application with groups that don't comply with the naming standard
        $ApplicationGroupNameWithBadGroupNames = [PSCustomObject]@{
            Name = "WSCVDI\GDE\GDE - WIN-PAK"; 
            ApplicationName = "GDE - WIN-PAK"; 
            AssociatedUserFullNames = "SCM_GG_GVA-ConsoleSCCM","GDE_LL_GVA- WIN-PAK"; 
            ScopeName = "WSCVDI";            
        }

    } 
       
    It "Should return the same scope name using pipeline" {
        $ApplicationGroupNameSameScope | Compare-ApplicationGroupName | ForEach-Object { $_.ScopeName | Should -Be "WSCVDI" }
    }
    
    It "Should return Not-Applicable for different scope name using pipeline" {
        $ApplicationGroupNameDiffScope | Compare-ApplicationGroupName | ForEach-Object { $_.ScopeName | Should -Be "Not-Applicable" }
    }
    
    It "Should return an error message using pipeline" {
        $ApplicationGroupNameWithBadGroupNames | Compare-ApplicationGroupName | ForEach-Object { $_.ErrorMessage | Should -Be "The AD Group Name does not comply with the naming standard." } 
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