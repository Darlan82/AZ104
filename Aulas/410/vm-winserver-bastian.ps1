# Login no Azure
Connect-AzAccount -UseDeviceAuthentication -TenantId "779f8684-b294-4046-a8f2-e55213029544"

# Parametros Gerais
$rg = 'rg-vmwin'
$local = 'brazilsouth'

# criar Grupo de Recursos
New-AzResourceGroup -Name $rg -Location $local

# Criar VNET e Subnet da VM
$snetvm = New-AzVirtualNetworkSubnetConfig -Name "default" -AddressPrefix 10.0.0.0/24
$vnet = New-AzVirtualNetwork -Name "vnet-vm" -ResourceGroupName $rg -Location $local -AddressPrefix 10.0.0.0/16 -Subnet $snetvm

# Parametros VMs
$vm = 'vm-win'
$sku = 'Standard_B2s'
$ip = 'ip-vm'
$azurevmpublisher = 'MicrosoftWindowsServer'
$azurevmoffer = 'WindowsServer'
$img = '2022-Datacenter'

# Parametros Credenciais
$user = 'azureuser'
$pass = ConvertTo-SecureString 'tr@inning2023' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $pass);

# Criar IP Publico da VM
$pip = New-AzPublicIpAddress -ResourceGroupName $rg -Location $local -Name $ip -AllocationMethod Static -IdleTimeoutInMinutes 4

# regra para Liberar Acesso RDP na VM
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "AllowRDP" -Protocol Tcp `
    -Direction Inbound -Priority 100 -SourceAddressPrefix "Internet" -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 3389 -Access Allow

#criar NSG com a Regra
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rg -Location $local -Name "nsg-vm" -SecurityRules $nsgRuleRDP

# Criar Network Interface (NIC)
$nic = New-AzNetworkInterface -Name "nic-vm" -ResourceGroupName $rg -Location $local -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Configuracoes da Virtual Machine
$vmconfig = New-AzVMConfig -VMName $vm -VMSize $sku
$vmconfig = Set-AzVMOperatingSystem -VM $vmconfig -Windows -ComputerName $vm -Credential $cred
$vmconfig = Add-AzVMNetworkInterface -VM $vmconfig -Id $nic.Id
$vmconfig = Set-AzVMBootDiagnostic -VM $vmconfig -Disable
$vmconfig = Set-AzVMSourceImage -VM $vmconfig -PublisherName $azurevmpublisher -Offer $azurevmoffer -Skus $img -Version "latest"

#Criar VM com Configuragoes declaradas
New-AzVM -ResourceGroupName $rg -Location $local -VM $vmconfig

# Excluir Politica de Liberacao RDP na porta 3389
Remove-AzNetworkSecurityRuleConfig -Name $nsgRuleRDP.Name -NetworkSecurityGroup $nsg
$nsg | Set-AzNetworkSecurityGroup

# bastion host
# Adicionar Subnet
$snetbastion = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix 10.0.1.0/26
$vnet.Subnets.Add($snetbastion)
$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet

#Criar IP Publico para o Bastion Host
$ipbastion = New-AzPublicIpAddress -ResourceGroupName $rg -Name "ip-bastion" -Location $local -AllocationMethod Static -Sku Standard

#Criar Bastion
New-AzBastion -ResourceGroupName $rg -Name "bastion" -PublicIpAddress $ipbastion -VirtualNetwork $vnet

#Excluir Grupo de Recursos
Remove-AzResourceGroup -Name $rg -Force -Confirm -AsJob