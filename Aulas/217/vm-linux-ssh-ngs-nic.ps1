#Login no Azure
Connect-AzAccount

#Obter Chave SSH
ssh-keygen -m PEM -t rsa -b 2048

# Parametros - Gerais
$rg = 'rg-linux'
$local = 'brazilsouth'

# Parametros - VM
$vm = 'vm-ubuntu'
$sku = 'Standard_B2s'
$img = 'UbuntuServer'
$imgversion = '18.04-LTS'

# Criar Grupo de Recursos
New-AzResourceGroup -Name $rg -Location $local

# Criar VNET e Subnet
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name "snet-vm" -AddressPrefix 192.168.1.0/24
$vnet = New-AzVirtualNetwork -ResourceGroupName $rg -Location $local -Name "vnet-vm" -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

#Criar IP Publico
$pip = New-AzPublicIpAddress -ResourceGroupName $rg -Location $local -AllocationMethod Static -Name "ip-publico"

# Criar Network Security Group - Regras SSH e HTTP
$nsgSSH = New-AzNetworkSecurityRuleConfig -Name "nsgSSH" -Protocol "Tcp" -Direction "Inbound" -Priority 1000 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access "Allow"

$nsgHTTP = New-AzNetworkSecurityRuleConfig -Name "nsgHTTP" -Protocol "Tcp" -Direction "Inbound" -Priority 1100 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access "Allow"

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rg -Location $local -Name "nsg-vm" -SecurityRules $nsgSSH, $nsgHTTP

#Criar NIC
$nic = New-AzNetworkInterface -Name "nic-vm" -ResourceGroupName $rg -Location $local -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Criar Maquina virtal do Azure
$pass = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser" , $pass)

$vmconfig = New-AzVMConfig -VMName $vm -VMSize $sku | Set-AzVMOperatingSystem -Linux -ComputerName $vm `
        -Credential $cred -DisablePasswordAuthentication | Set-AzVMSourceImage -PublisherName "Canonical" `
        -Offer $img -Skus $imgversion -Version "latest" | Add-AzVMNetworkInterface -Id $nic.Id

# Configurar chave SSH
$sshkey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublickey -VM $vmconfig -KeyData $sshKey -Path "/home/azureuser/.ssh/authorized_keys"

#Criar VM
New-AzVM -ResourceGroupName $rg -Location $local -VM $vmconfig

# Obter IP Publico
$publicIp = (Get-AzPublicIpAddress -ResourceGroupName $rg -Name "ip-publico").IpAddress
$sshUser =  'azureuser@' + $publicIp

# Acessar via SSH - Porta 22 Liberada no NSG
ssh -i $sshKey $sshUser

#Instalar NGINX Web Server
sudo apt-get update && sudo apt-get install -y nginx
exit

curl $publicIp

# Excluir Grupo de Recursos
Remove-AzResourceGroup -Name $rg