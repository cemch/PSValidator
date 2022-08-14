Describe "Test Compare-String" {

    It "Should return True if StringValue matches the Regex" {
        Compare-String -StringValue "C_APPBLU" -Regex '^C_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}' | Should -BeTrue
    }

    It "Should return False if StringValue does not match the Regex" {
        Compare-String -StringValue "D_APPBLU" -Regex '^C_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}' | Should -BeFalse
    }
}

Describe "Test Compare-CatalogName" {

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

Describe "Test Compare-DesktopGroupName" {

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

Describe "Test Get-LogPath" {

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

Describe "Tests for Write-InvalidNameToLogFile" {

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