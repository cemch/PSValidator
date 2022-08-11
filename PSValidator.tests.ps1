Describe "Test Compare-String" {

    It "Test if the function Compare-String returns True" {
        Compare-String -StringValue "C_APPBLU" -Regex '^C_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}' | Should -BeTrue
    }

    It "Test if the function Compare-String returns False" {
        Compare-String -StringValue "D_APPBLU" -Regex '^C_[APPBLU|APPGRE|APPIND|APPRED|APPYEL|WSCEMS|WSCVDI]{6}' | Should -BeFalse
    }
}

Describe "Test Compare-CatalogName" {

    It "Test a valid catalog name and should return True" {
        (Compare-CatalogName -Name "C_APPRED_AZY-PRD" -ScopeName "APPRED").IsValid | Should -BeTrue
    }

    It "Test a valid catalog name and should return  False" {
        (Compare-CatalogName -Name "C_ABCDEF_AZY-PRD" -ScopeName "APPRED").IsValid | Should -BeFalse
    }
    
    It "Test an array of valid catalog names and should return True" {
        $catalogNames = "C_APPRED_AZY-PRD","C_APPRED_AZY-DEV"; 
        $catalogNames | Compare-CatalogName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeTrue }
    }

    It "Test an array of valid catalog names and should return False" {
        $catalogNames = "C_APP111_AZY-PRD","C_APP222_AZY-DEV"; 
        $catalogNames | Compare-CatalogName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeFalse }
    }
}

Describe "Test Compare-DesktopGroupName" {

    It "Test a valid desktop group name and should return True" {
        (Compare-DesktopGroupName -Name "D_APPRED_AZY-PRD" -ScopeName "APPBLU").IsValid | Should -BeTrue
    }

    It "Test a valid desktop group name and should return  False" {
        (Compare-DesktopGroupName -Name "D_ABCDEF_AZY-PRD" -ScopeName "APPBLU").IsValid | Should -BeFalse
    }

    It "Test an array of valid desktop group names and should return True" {
        $desktopGroups = "D_APPRED_AZY-PRD","D_APPRED_AZY-DEV"; 
        $desktopGroups | Compare-DesktopGroupName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeTrue }
    }

    It "Test an array of valid desktop group names and should return False" {
        $desktopGroups = "D_APP111_AZY-PRD","D_APP222_AZY-DEV"; 
        $desktopGroups | Compare-DesktopGroupName -ScopeName "APPRED" | ForEach-Object { $_.IsValid | Should -BeFalse }
    }
}

Describe "Test Get-LogPath" {

    It "The function Get-LogPath should return a valid path" {
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