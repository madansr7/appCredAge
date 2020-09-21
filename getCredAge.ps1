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
    $credList = New-Object -TypeName psobject


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
        #Write-Host PwdAge: $foo days
        $credList | Add-Member -MemberType NoteProperty -Name $item.keyId -Value $foo 
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
foreach($app in $appList)
{
    $currentDate = Get-Date 
    #Write-Host $app.ObjectId
    $certs = GetKeyCredentials -objId $app.ObjectId
    $pwds = GetPasswordCredentials -objId $app.ObjectId

    $appInfo = New-Object -TypeName psobject
    $appInfo | Add-Member -MemberType NoteProperty -Name certs -Value $certs
    $appInfo | Add-Member -MemberType NoteProperty -Name pwds -Value $pwds
    #[pscustomobjec]@{
    #app = $app.ObjectId
    #certs = GetKeyCredentials -objId $app.ObjectId
    #pwds = GetPasswordCredentials -objId $app.ObjectId
    #}
    
    Write-Host $appInfo
    
}

