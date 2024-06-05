@description('Deploys a vulnerable Azure Storage account.')
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS' // Vulnerability: Using LRS instead of more secure options like GRS
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: false // Vulnerability: Allowing HTTP traffic
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageAccount.name}/vulnerablecontainer'
  properties: {
    publicAccess: 'Container' // Vulnerability: Container-level public access
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: '${storageAccountName}-sql'
  location: resourceGroup().location
  properties: {
    administratorLogin: 'adminUser' // Vulnerability: Using a common username
    administratorLoginPassword: 'Password123!' // Vulnerability: Weak password
  }
  resources: [
    {
      name: 'firewallRule'
      type: 'firewallRules'
      apiVersion: '2021-05-01-preview'
      properties: {
        startIpAddress: '0.0.0.0' // Vulnerability: Allowing all IPs
        endIpAddress: '255.255.255.255' // Vulnerability: Allowing all IPs
      }
    }
  ]
}

output storageAccountEndpoint string = storageAccount.properties.primaryEndpoints.blob
