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

    $cred = Get-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId  | select KeyId, StartDate, EndDate
    $credList = @{}

    if ($cred -ne $null) 
    {
        foreach($item in $cred)
        {
            $diff = $currentDate.Subtract($item.StartDate)
            $foo= [System.Math]::Round($diff.TotalDays)
            $credList.Add($item.keyId, $foo)
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
    <#$credList = New-Object -TypeName psobject

    if ($keyCred -ne $null) 
    {
        foreach($item in $keyCred)
        {
            $diff = $currentDate.Subtract($item.StartDate)
            $foo= [System.Math]::Round($diff.TotalDays)
            $credList | Add-Member -MemberType NoteProperty -Name $item.keyId -Value $foo 
        }
    }
    return $credList #>
    $credList = @{}

    if ($cred -ne $null) 
    {
        foreach($item in $cred)
        {
            $diff = $currentDate.Subtract($item.StartDate)
            $foo= [System.Math]::Round($diff.TotalDays)
            $credList.Add($item.keyId, $foo)
        }
        
    }
    return $credList
}

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

