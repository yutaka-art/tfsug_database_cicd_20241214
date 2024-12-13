param envFullName string
param envShortName string
param envTargetName string

param storageAccountName string = 'st${envShortName}${envTargetName}001'
param acrName string = 'cr${envShortName}${envTargetName}001'
param keyVaultName string = 'kv${envShortName}${envTargetName}001'

param logAnalyticsWorkspaceName string = 'log-${envFullName}-${envTargetName}-001'
param appInsightsName string = 'appi-${envFullName}-${envTargetName}-001'
param hostingPlanName string = 'asp-${envFullName}-${envTargetName}-001'
param appServiceName string = 'app-${envFullName}-${envTargetName}-001'

param sqlServerName string = 'sql${envShortName}${envTargetName}001'
param sqlDBName string = 'EventTrackerDB'

@description('The administrator username of the SQL logical server.')
param administratorLogin string
@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

param location string = resourceGroup().location

// LogAnalyticsWorkspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    WorkspaceResourceId:logAnalyticsWorkspace.id
  }
}

// Storage account
var strageSku = 'Standard_LRS'
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku:{
    name: strageSku
  }
}

// Azure Container Registry
param acrSku string = 'Basic'
resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}

// App Service Plan
resource hostingPlan  'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
    size: 'F1'
    family: 'F'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true // for Linux
  }
}

// App Service
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrName}.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrName
        }
        {
          name: 'KEY_VAULT_URL'
          value: 'https://${keyVaultName}.vault.azure.net/'
        }
        {
          name: 'TZ'
          value: 'Asia/Tokyo'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Staging'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/eventattendeesapp:latest'
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      keyVaultReferenceIdentity: 'SystemAssigned'
      http20Enabled: true
    }
    httpsOnly: true
  }
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

// SQL Database
resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
//    networkAcls: {
//      bypass: 'None'
//      defaultAction: 'Deny'
//    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    tenantId: tenant().tenantId
  }
}

// Key Vault Secrets
resource eventAttendeesAppEventTrackerDB 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'EventAttendeesApp--DatabaseName'
  properties: {
    value: '${sqlDBName}'
  }
}

resource eventAttendeesAppSqlDbConnection 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'EventAttendeesApp--SqlDbConnection'
  properties: {
    value: 'Server=${sqlServerName}.database.windows.net;Database=EventTrackerDB;User Id=${administratorLogin};Password=${administratorLoginPassword};'
  }
}

resource eventAttendeesAppSqlPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'EventAttendeesApp--SqlPassword'
  properties: {
    value: '${administratorLoginPassword}'
  }
}

resource eventAttendeesAppSqlServerName 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'EventAttendeesApp--SqlServerName'
  properties: {
    value: '${sqlServerName}.database.windows.net'
  }
}

resource eventAttendeesAppSqlUsername 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'EventAttendeesApp--SqlUsername'
  properties: {
    value: '${administratorLogin}'
  }
}

