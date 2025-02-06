# Login na conta do Azure com Azure Powershell
Connect-AzAccount -UseDeviceAuthentication -TenantId "740d3ffe-a97c-4991-b909-c38b04b1b454"

$resourceGroup = "gruporecurso-pwsh"
$servicePlanName = "plan-pwsh"
$location = "brazilsouth"

# Criar Grupo de Recursos
New-AzResourceGroup -Name $resourceGroup -Location $location 

# Criar App Service Plan da maneira mais simplificada
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $servicePlanName -Location $location 

# Mostrar Detalhes do App Plan
Get-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $servicePlanName

# Listando todos os App Service Plans
Get-AzAppServicePlan

# Excluindo App Service Plan
Remove-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $servicePlanName

# Criar App Service Plan com Plano Basic
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $servicePlanName -Location $location -Tier Basic

# Atualizar App Service Plan com Plano Free
Set-AzAppServicePlan -Name $servicePlanName -ResourceGroupName $resourceGroup -Tier Free

# Excluir App Service Plan
Remove-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $servicePlanName

# Excluir Grupo de Recursos
Remove-AzResourceGroup -Name $resourceGroup