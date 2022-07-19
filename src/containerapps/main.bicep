param location string = resourceGroup().location
param uniqueSeed string = '${resourceGroup().id}-${deployment().name}'

param registry string
param registryUsername string
@secure()
param registryPassword string

param objectId string

////////////////////////////////////////////////////////////////////////////////
// Infrastructure
////////////////////////////////////////////////////////////////////////////////
module storage 'infra/storage.bicep' = {
  name: '${deployment().name}-infra-storage'
  params: {
    location: location
    entryCamContainerName: 'trafficcontrol-entrycam'
    exitCamContainerName: 'trafficcontrol-exitcam'
    uniqueSeed: uniqueSeed
  }  
}

module containerAppsEnvironment 'infra/container-apps-env.bicep' = {
  name: '${deployment().name}-infra-container-app-env'
  params: {
    location: location
    uniqueSeed: uniqueSeed
  }
}

module cosmos 'infra/cosmos-db.bicep' = {
  name: '${deployment().name}-infra-cosmos-db'
  params: {
    location: location
    uniqueSeed: uniqueSeed
  }
}

module serviceBus 'infra/service-bus.bicep' = {
  name: '${deployment().name}-infra-service-bus'
  params: {
    location: location
    uniqueSeed: uniqueSeed
  }
}

module MailDev 'apps/MailDev.bicep' = {
  name: '${deployment().name}-maildev'
  params: {
    location:location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
  }
}

module mqtt 'infra/mqtt.bicep' = {
  name: 'mqttDeploy'
  params: {
    location:location
    uniqueSeed: uniqueSeed
  }  
}

module keyvault 'infra/keyvault.bicep' = {
  name: '${deployment().name}-keyvault'
  params: {
    location:location
    uniqueSeed: uniqueSeed
    objectId: objectId
    secretName: 'licensekey'
    secretValue: 'HX783-K2L7V-CRJ4A-5PN1G'
  }
}


resource keyVaultReader 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyvault.outputs.name
}

////////////////////////////////////////////////////////////////////////////////
// Dapr components
////////////////////////////////////////////////////////////////////////////////
module daprPubSub 'dapr/pubsub.bicep' = {
  name: '${deployment().name}-dapr-pubsub'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    serviceBusConnectionString: serviceBus.outputs.connectionString
  }
}

module daprStateStore 'dapr/statestore.bicep' = {
  name: '${deployment().name}-dapr-statestore'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    cosmosDbName: cosmos.outputs.cosmosDbName
    cosmosCollectionName: cosmos.outputs.cosmosCollectionName
    cosmosUrl: cosmos.outputs.cosmosUrl
    cosmosKey: cosmos.outputs.cosmosKey
  }
}

module daprEmail 'dapr/email.bicep' = {
  name: '${deployment().name}-dapr-email'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    host: MailDev.outputs.fqdn
    port: '4025'
    smtppassword: '_password'
    smtpuser: '_username'
  }
}

module daprEntrycam 'dapr/entrycam.bicep' = {
  name: '${deployment().name}-dapr-entrycam'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    connectionString: mqtt.outputs.eventHubEntryCamConnectionString
    consumerGroup: 'trafficcontrolservice'
    storageAccountKey: storage.outputs.storageAccountContainerKey
    storageAccountName: storage.outputs.storageAccountName
    storageContainerName: storage.outputs.storageAccountEntryCamContainerName
  }
}

module daprExitcam 'dapr/exitcam.bicep' = {
  name: '${deployment().name}-dapr-exitcam'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    connectionString: mqtt.outputs.eventHubExitCamConnectionString
    consumerGroup: 'trafficcontrolservice'
    storageAccountKey: storage.outputs.storageAccountContainerKey
    storageAccountName: storage.outputs.storageAccountName
    storageContainerName: storage.outputs.storageAccountExitCamContainerName
  }
}

////////////////////////////////////////////////////////////////////////////////
// Container apps
////////////////////////////////////////////////////////////////////////////////
module VehicleRegistrationService 'apps/VehicleRegistrationService.bicep' = {
  name: '${deployment().name}-app-vehicleregistration-svc'
  dependsOn: [
    FineCollectionService
  ]
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    registry: registry
    registryUsername: registryUsername
    registryPassword: registryPassword
  }
}

module FineCollectionService 'apps/FineCollectionService.bicep' = {
  name: '${deployment().name}-app-finecollection-svc'
  dependsOn: [
    daprEmail
    MailDev
    daprPubSub
  ]
  params: {
    location: location
    keyvault: keyvault.name
    licensekey: keyVaultReader.getSecret('licensekey')
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    registry: registry
    registryUsername: registryUsername
    registryPassword: registryPassword  
  }
}

module TrafficControlService 'apps/TrafficControlService.bicep' = {
  name: '${deployment().name}-app-trafficcontrol-svc'
  dependsOn: [
    daprStateStore
    daprPubSub
    mqtt
  ]
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    registry: registry
    registryUsername: registryUsername
    registryPassword: registryPassword
  }
}
