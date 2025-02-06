# Login na conta do Azure com Azure Powershell
Connect-AzAccount -UseDeviceAuthentication -TenantId "740d3ffe-a97c-4991-b909-c38b04b1b454"

$resourceGroup = "gruporecurso-pwsh"
$servicePlanName = "plan-pwsh"
$location = "brazilsouth"
$WebAppName = "appservicetrein98596"

# Criar Grupo de Recursos
New-AzResourceGroup -Name $resourceGroup -Location $location 

# Criar App Service Plan da maneira mais simplificada
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $servicePlanName -Location $location 

# Criar App Service com Plano Basic
New-AzWebApp -ResourceGroupName $resourceGroup -Name $WebAppName -Location $location -AppServicePlan $servicePlanName

# Detalhes do App Service
Get-AzWebApp -ResourceGroupName $resourceGroup -Name $WebAppName

# Stop App Service
Stop-AzWebApp -ResourceGroupName $resourceGroup -Name $WebAppName

# Start App Service
Start-AzWebApp -ResourceGroupName $resourceGroup -Name $WebAppName

# Restart App Service
Restart-AzWebApp -ResourceGroupName $resourceGroup -Name $WebAppName

# Remove App Service
Remove-AzWebApp -ResourceGroupName $resourceGroup -Name $WebAppName
