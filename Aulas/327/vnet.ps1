# Login no Azure
Connect-AzAccount -Tenant "740d3ffe-a97c-4991-b909-c38b04b1b454"

# Parametros
$rg = 'rg-vnet-powershell'
$local = 'brazilsouth'
$vnetname = 'vnet-powershell'

# Criar Grupo de Recursos
New-AzResourceGroup -Name $rg -Location $local

# Criar VNET e Subnet
$snet = New-AzVirtualNetworkSubnetConfig -Name 'snet-1' -AddressPrefix 10.0.0.0/24
New-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg -Location $local -AddressPrefix 10.0.0.0/16 -Subnet $snet

# Listar VNETs
Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg

# Excluir VNET
Remove-AzvirtualNetwork -Name $vnetname -ResourceGroupName $rg

# Criar Multiplas Subnerts na VNET
$snet1 = New-AzVirtualNetworkSubnetConfig -Name 'snet-1' -AddressPrefix 10.3.1.0/24
$snet2 = New-AzVirtualNetworkSubnetConfig -Name 'snet-2' -AddressPrefix 10.3.2.0/24
New-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg -Location $local -AddressPrefix 10.3.0.0/16 -Subnet $snet1, $snet2

# Obter AddressPrefix da Subnet 1
$vnet = Get-AzVirtualNetwork -Name $vnetname
Get-AzVirtualNetworkSubnetConfig -Name 'snet-1' -VirtualNetwork $vnet | Select-Object AddressPrefix

# Adicionar Subnet em VNET ja existente
# Obter Subnet 1 e 2
$snet1 = Get-AzVirtualNetworkSubnetConfig -Name 'snet-1' -VirtualNetwork $vnet
$snet2 = Get-AzVirtualNetworkSubnetConfig -Name 'snet-2' -VirtualNetwork $vnet
# Criar nova Subnet
$snet3 = New-AzVirtualNetworkSubnetconfig -Name 'snet-3' -AddressPrefix 10.3.3.0/24

# Adicionar Subnet 3 e Sobrescrever VNET
New-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg -Location $local -AddressPrefix 10.3.0.0/16 -Subnet $snet1, $snet2, $snet3 | Set-AzVirtualNetwork

# Excluir Grupo de Recursos e VNET/Subnet
Remove-AzResourceGroup -Name $rg -Force