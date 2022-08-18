# PSValidator.ps1

The last line of the script starts the validations: 
```
Start-Validation -ScopeName "APPBLU"
```
## -ScopeName
The name of the scope to validate. 

## Delivery Controllers
Please change admin IP Address 
```
Get-BrokerSite -AdminAddress 127...
```