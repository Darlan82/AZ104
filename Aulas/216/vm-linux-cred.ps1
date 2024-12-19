#Login no Azure
Connect-AzAccount

# Parametros - Gerais
$rg = 'rg-vmlinux'
$local = 'brazilsouth'

# Parametros - VM
$vm = 'vm-ubuntu'
$sku = 'Standard_B2s'
$img = 'Ubuntu2204'
$ip = 'ip-vm'
$nsg = 'nsg-vm'

# Parametros - Credenciais
$user = 'azureuser'
$pass = ConvertTo-SecureString 'tr@ining2023' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $pass);

# Criar Grupo de Recursos
New-AzResourceGroup -Name $rg -Location $local

#Criar Maquina Virtual 
New-AzVM -Name $vm -ResourceGroupName $rg -Credential $cred -Image $img -PublicIpAddressName $ip -Size $sku -Location $local

# Excluir Grupo de Recursos
Remove-AzResourceGroup -Name $rg