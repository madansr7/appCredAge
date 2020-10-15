Import-Module AzureAD


function GetPasswordCredentials
{
    param
    (
        [string]
        [Parameter(Mandatory=$true)]
        $objId
    )

    $cred = Get-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId  | select KeyId, StartDate, EndDate
    $credList = @{}

    if ($cred -ne $null) 
    {
        foreach($item in $cred)
        {
            $diff = $currentDate.Subtract($item.StartDate)
            $totalDay= [System.Math]::Round($diff.TotalDays)
            $credList.Add($item.keyId, $totalDay)
        }
        
    }
    return $credList
}

function GetKeyCredentials
{
    param
    (
        [string]
        [Parameter(Mandatory=$true)]
        $objId
    )
    $cred = Get-AzureADApplicationKeyCredential -ObjectId $app.ObjectId
    $credList = @{}

    if ($cred -ne $null) 
    {
        foreach($item in $cred)
        {
            $diff = $currentDate.Subtract($item.StartDate)
            $totalDay= [System.Math]::Round($diff.TotalDays)
            $credList.Add($item.keyId, $totalDay)
        }
        
    }
    return $credList
}

function GetSessionInfo()
{
    try{
        $sessionInfo = Get-AzureADCurrentSessionInfo
    }
    catch{
        Write-Warning -Message "Need to connect to Azure AD"
    }
    return $sessionInfo
}


function CredAge
{
    <#
    EXAMPLE
    PS> CredAge -LogFile "C:\credLogs.txt"
    #>
    
    param
    (
        [string]
        [Parameter(Mandatory=$true)]
        $LogFile
    )

    $currentSessionInfo = GetSessionInfo


    if (!$currentSessionInfo)
    {
        Connect-AzureAD
    }  
    
     
$appList = Get-AzureADApplication | select ObjectId
$appInfoList = @{}


try
{

    foreach($app in $appList)
    {
        $currentDate = Get-Date 
        $appInfo = [pscustomobject]@{
        certs = GetKeyCredentials -objId $app.ObjectId
        pwds = GetPasswordCredentials -objId $app.ObjectId
        }
    
        $appInfoList.Add($app.ObjectId,$appInfo)
    }

    $appInfoList | ConvertTo-json | Out-File -FilePath $LogFile
}
catch
{
    $errorMsg = "Could not process request" 
    $errorMsg | Out-File -FilePath $LogFile
}
}

CredAge
















































<#

$appList = Get-AzureADApplication | select ObjectId
$appInfoList = @{}

foreach($app in $appList)
{
    $currentDate = Get-Date 
    $appInfo = [pscustomobject]@{
    certs = GetKeyCredentials -objId $app.ObjectId
    pwds = GetPasswordCredentials -objId $app.ObjectId
    }
    
    $appInfoList.Add($app.ObjectId,$appInfo)
}

$appInfoList | ConvertTo-json

#>