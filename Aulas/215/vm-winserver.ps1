#Login no Azure
Connect-AzAccount

# Parametros - Gerais
$rg = 'rg-vmwin'
$local = 'brazilsouth'

# Parametros - VM
$vm = 'vm-win'
$sku = 'Standard_B2s'
$img = 'Win2019Datacenter'
$ip = 'ip-vm'
$nsg = 'nsg-vm'

# Parametros - Credenciais
$user = 'azureuser'
$pass = ConvertTo-SecureString 'tr@ining2023' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $pass);

# Criar Grupo de Recursos
New-AzResourceGroup -Name $rg -Location $local

#Criar Maquina Virtual com Windows Server
New-AzVM -Name $vm -ResourceGroupName $rg -Credential $cred -Image $img -PublicIpAddressName $ip -Size $sku -Location $local

# Selecionar NSG Criado na VM
$nsg = Get-AzNetworkSecurityGroup -Name $vm -ResourceGroupName $rg

# Liberar Porta 80 - Parametros
$Params = @{
    'Name'                     = 'allowHTTP'
    'NetworkSecurityGroup'     = $nsg
    'Protocol'                 = 'TCP'
    'Direction'                = 'Inbound'
    'Priority'                 = 100
    'SourceAddressPrefix'      = 'Internet'
    'SourcePortRange'          = '*'
    'DestinationAddressPrefix' = '*'
    'DestinationPortRange'     = 80
    'Access'                   = 'Allow'
}

# Adicionar Regra ao NSG
Add-AzNetworkSecurityRuleConfig @Params | Set-AzNetworkSecurityGroup

# Instalar IIS Web Server
Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vm -CommandId 'RunPowerShellScript' -ScriptString 'Install-WindowsFeature -Name Web-Server -IncludeManagementTools'

# Listar IP
Get-AzPublicIpAddress -ResourceGroupName $rg -Name $ip | select IpAddress # 191.232.184.233

# Entrar no Site
curl 191.232.184.233

# Alterar HTML no IIS Web Server
Set-AzVMExtension -ResourceGroupName $rg -ExtensionName "IIS" -VMName $vm -Location $local -Publisher Microsoft.Compute `
-ExtensionType CustomScriptExtension -TypeHandlerVersion 1.8 `
-SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

# Excluir Grupo de Recursos
Remove-AzResourceGroup -Name $rg