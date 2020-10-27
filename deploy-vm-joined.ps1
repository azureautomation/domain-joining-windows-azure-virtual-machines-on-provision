<#
  Creates a Virtual Machine that is domain joined on boot
  Use Get-AzurePublishSettingsFile and Import-AzurePublishSettings file to import your subscription settings
  
  Pre-Requisites: Connected to an on-premises environment with AD 
  OR 
  AD deployed in another virtual machine and DNS configured.
  See: http://michaelwasham.com/2012/07/13/connecting-windows-azure-virtual-machines-with-powershell/ for more examples
  
  
  Author: Michael Washam
  Website: http://michaelwasham.com
  Twitter: MWashamMS
#>

# Retrieve with Get-AzureSubscription 
$subscriptionName = '[MY SUBSCRIPTION]'  

# Retreive with Get-AzureStorageAccount
$storageAccountName = '[MY STORAGE ACCOUNT]'   

# Specify the storage account location to store the newly created VHDs 
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName 
 
# Select the correct subscription (allows multiple subscription support) 
Select-AzureSubscription -SubscriptionName $subscriptionName 


# Enumerate available locations with Get-AzureLocation. 
# Must be the same as your virtual network affinity group.
$affinityGroup = '[VNET Affinity Group]'

# Retrieve Server 2012 image name with Get-AzureVMImage
$imageName = 'MSFT__Windows-Server-2012-Datacenter-201210.01-en.us-30GB.vhd'

# ExtraSmall, Small, Medium, Large, ExtraLarge
$instanceSize = 'Medium' 

# Has to be a unique name. Verify with Test-AzureService
$serviceName = '[UNIQUE SERVICE NAME]' 

# Member Server Name
$vmname1 = 'domjoinedvm1'

# Subnet from Existing Virtual Network
$subnet = '[YOUR SUBNET NAME]'
$vnetName = '[YOUR VNET NAME]' 

# Domain join settings
$domain = '[YOUR DOMAIN]'
$domainjoin = '[YOUR DOMAIN FQDN]'
$domainuser = '[DOMAIN ADMIN]'
$domainpwd = '[DOMAIN ADMIN PASSWORD]' 


$advm1 = New-AzureVMConfig -Name $vmname1 -InstanceSize $instanceSize -ImageName $imageName |
	Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $domainjoin -Domain $domain -DomainPassword $domainpwd -Password $domainpwd -DomainUserName $domainuser | 
	Set-AzureSubnet -SubnetNames $subnet 

New-AzureVM -ServiceName $serviceName -AffinityGroup $affinityGroup -VMs $advm1 -VNetName $vnetName 