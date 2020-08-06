#╔=======================================================================================╗
#║ PS Script:   Create Network Security Group (Inbound/Outbound rules) in Subscriptions  ║
#║ Version:     1.00                                                                     ║
#║ Date:        2020-08-04                                                               ║
#║ Created by:  Cibin Albin                                                              ║
#╚=======================================================================================╝

# Change log
# 2020-08-04 Version: 1.00 - Initial version

<#
  .SYNOPSIS
    Create NSG rules under a subscription
  
  
  .DESCRIPTION
    This Script is made to create Inbound and Outbound rules under a Subscription.
    First, Update a excelsheet(.csv) and then update the mentioned columns in the provided template and run the script.

    Build using Azure Powershell AZ modules version 1.00

  .EXAMPLE 
    Run script in powershell using Admin account, while connected to a subscription.
#>

param(
[Parameter(Mandatory=$True)]
[string]
$SubscriptionName,
[Parameter(Mandatory=$True)]
[string]
$resourceGroupName,

[string]
$nsgName,

[string]
$nsgRuleName,
[string]
$nsgRuleDescription,
[string]
$nsgRuleAccess,
[string]
$nsgRuleProtocol,
[string]
$nsgRuleDirection,
[string]
$nsgRulePriority,
[string]
$nsgRuleSourceAddressPrefix,
[string]
$nsgRuleSourcePortRange,
[string]
$nsgRuleDestinationAddressPrefix,
[string]
$nsgRuleDestinationPortRange,
$csvFilePath = "C:\CIBIN\CLOUD-APAC\Automation-Script\trail.csv"
)

# sign in
Write-Host "Logging in...";
Connect-AzAccount;

# select subscription
Write-Host "Selecting subscription '$SubscriptionName'";
Select-AzSubscription -Subscription $SubscriptionName;

Import-Csv $csvFilePath |`
  ForEach-Object {
    $nsgName = $_."NSG Name"
    $nsgRuleName = $_."NSG Rule Name"
        $nsgRuleDescription = $_."NSG Rule Description"
    $nsgRuleAccess = $_."NSG Rule Access"
        $nsgRuleProtocol = $_."NSG Rule Protocol"
    $nsgRuleDirection = $_."NSG Rule Direction"
        $nsgRulePriority = $_."NSG Rule Priority"
    $nsgRuleSourceAddressPrefix = $_."NSG Rule Source Address Prefix"
        $nsgRuleSourcePortRange = $_."NSG Rule Source Port Range"
    $nsgRuleDestinationAddressPrefix = $_."NSG Rule Destination Address Prefix"
        $nsgRuleDestinationPortRange = $_."NSG Rule Destination Port Range"

    #Getting the right NSG and setting new rule to it    
    $nsgRuleNameValue = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName | 
       Get-AzNetworkSecurityRuleConfig -Name $nsgRuleName -ErrorAction SilentlyContinue
    if($nsgRuleNameValue.Name -match $nsgRuleName){
       Write-Host "A rule with this name (" $nsgRuleNameValue.Name ") already exists"
       }
    else{
         Get-AzNetworkSecurityGroup -Name  $nsgName -ResourceGroupName $resourceGroupName |
        Add-AzNetworkSecurityRuleConfig -Name $nsgRuleName -Description $nsgRuleDescription -Access $nsgRuleAccess `
         -Protocol $nsgRuleProtocol -Direction $nsgRuleDirection -Priority $nsgRulePriority -SourceAddressPrefix $nsgRuleSourceAddressPrefix.split(";") -SourcePortRange $nsgRuleSourcePortRange `
              -DestinationAddressPrefix $nsgRuleDestinationAddressPrefix -DestinationPortRange $nsgRuleDestinationPortRange.split(";") -Verbose | 
        Set-AzNetworkSecurityGroup -Verbose
       }
    }