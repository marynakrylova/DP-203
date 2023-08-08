Clear-Host
write-host "Starting script at $(Get-Date)"

# Handle cases where the user has multiple subscriptions
$subs = Get-AzSubscription | Select-Object
if($subs.GetType().IsArray -and $subs.length -gt 1){
        Write-Host "You have multiple Azure subscriptions - please select the one you want to use:"
        for($i = 0; $i -lt $subs.length; $i++)
        {
                Write-Host "[$($i)]: $($subs[$i].Name) (ID = $($subs[$i].Id))"
        }
        $selectedIndex = -1
        $selectedValidIndex = 0
        while ($selectedValidIndex -ne 1)
        {
                $enteredValue = Read-Host("Enter 0 to $($subs.Length - 1)")
                if (-not ([string]::IsNullOrEmpty($enteredValue)))
                {
                    if ([int]$enteredValue -in (0..$($subs.Length - 1)))
                    {
                        $selectedIndex = [int]$enteredValue
                        $selectedValidIndex = 1
                    }
                    else
                    {
                        Write-Output "Please enter a valid subscription number."
                    }
                }
                else
                {
                    Write-Output "Please enter a valid subscription number."
                }
        }
        $selectedSub = $subs[$selectedIndex].Id
        Select-AzSubscription -SubscriptionId $selectedSub
        az account set --subscription $selectedSub
}


$resourceGroupName = "dp203-s87e6yt"
$storageAccountName = "storemakr"
$eventNsName = "eventsmakr"
$eventHubName = "eventhubmakr"


# Prepare JavaScript EventHub client app
write-host "Creating Event Hub client app..."
npm install @azure/event-hubs | Out-Null
Update-AzConfig -DisplayBreakingChangeWarning $false | Out-Null
$conStrings = Get-AzEventHubKey -ResourceGroupName $resourceGroupName -NamespaceName $eventNsName -AuthorizationRuleName "RootManageSharedAccessKey"
$conString = $conStrings.PrimaryConnectionString
$javascript = Get-Content -Path "setup.txt" -Raw
$javascript = $javascript.Replace("EVENTHUBCONNECTIONSTRING", $conString)
$javascript = $javascript.Replace("EVENTHUBNAME",$eventHubName)
Set-Content -Path "orderclient.js" -Value $javascript

write-host "Script completed at $(Get-Date)"
