#Import-Module AzureAD
#Connect-AzureAD

function GetPasswordCredentials
{
    param
    (
        [string]
        [Parameter(Mandatory=$true)]
        $objId
    )

    $currentDate = Get-Date 
    $cred = Get-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId  | select KeyId, StartDate, EndDate

    if ($cred -ne $null) 
    {
        foreach($item in $cred)
        {
        #Write-Host $currentDate - $item.StartDate  
        #$diff1 = New-TimeSpan -Start $item.StartDate -End $currentDate
        #$diff2 = [DateTime]$currentDate-[DateTime]$item.StartDate
        $diff = $currentDate.Subtract($item.StartDate)
        #Write-Host $diff1.TotalDays
        $foo= [System.Math]::Round($diff.TotalDays)
        Write-Host PwdAge: $foo days
        
        }
        
    }

}

function GetKeyCredentials
{
    param
    (
        [string]
        [Parameter(Mandatory=$true)]
        $objId
    )
    $keyCred = Get-AzureADApplicationKeyCredential -ObjectId $app.ObjectId
    
    if ($keyCred -ne $null) 
    {
        foreach($item in $keyCred)
        {
            
            $diff = $currentDate.Subtract($item.StartDate)
            $foo= [System.Math]::Round($diff.TotalDays)
            Write-Host CertAge: $foo days
        }
    }

    #return $keyCred
}

$appList = Get-AzureADApplication | select ObjectId
foreach($app in $appList)
{
    $currentDate = Get-Date 
    Write-Host $app.ObjectId
    $keyid = GetKeyCredentials -objId $app.ObjectId
    $secretCred = GetPasswordCredentials -objId $app.ObjectId
    
}





#        $diff = New-TimeSpan -Start $currentDate -End [DateTime] $item.StartDate 
#        Write-Host $diff.TotalDays