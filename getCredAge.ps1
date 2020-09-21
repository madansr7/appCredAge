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
            $name = $item.keyId
            $value = $foo

            $credInfo = [pscustomobject]@{
            name = $item.keyId
            value = $foo
            }
            $credList.Add($name, $value)
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
    $keyCred = Get-AzureADApplicationKeyCredential -ObjectId $app.ObjectId
    $credList = New-Object -TypeName psobject

    if ($keyCred -ne $null) 
    {
        foreach($item in $keyCred)
        {
            
            $diff = $currentDate.Subtract($item.StartDate)
            $foo= [System.Math]::Round($diff.TotalDays)
            #Write-Host CertAge: $foo days
            $credList | Add-Member -MemberType NoteProperty -Name $item.keyId -Value $foo 

        }
    }

    return $credList
}

$appList = Get-AzureADApplication | select ObjectId
$appInfoList = @{}

foreach($app in $appList)
{
    $currentDate = Get-Date 
    #Write-Host $app.ObjectId
<#    $certs = GetKeyCredentials -objId $app.ObjectId
    $pwds = GetPasswordCredentials -objId $app.ObjectId

    $appInfo = New-Object -TypeName psobject
    $appInfo | Add-Member -MemberType NoteProperty -Name ObjectId -Value $app.ObjectId
    $appInfo | Add-Member -MemberType Property  -Name certs -Value $certs
    $appInfo | Add-Member -MemberType Property -Name pwds -Value $pwds #>
    
    $appInfo = [pscustomobject]@{
    #app = $app.ObjectId
    certs = GetKeyCredentials -objId $app.ObjectId
    pwds = GetPasswordCredentials -objId $app.ObjectId
    }
    
    
    $appInfoList.Add($app.ObjectId,$appInfo)
}

$appInfoList | ConvertTo-json

