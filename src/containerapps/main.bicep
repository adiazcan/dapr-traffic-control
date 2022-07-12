param location string = resourceGroup().location
param uniqueSeed string = '${resourceGroup().id}-${deployment().name}'

param registry string
param registryUsername string
@secure()
param registryPassword string

////////////////////////////////////////////////////////////////////////////////
// Infrastructure
////////////////////////////////////////////////////////////////////////////////

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
    host: 'localhost'
    port: '4025'
    smtppassword: '_password'
    smtpuser: '_username'
  }
}

module daprEntrycam 'dapr/entrycam.bicep' = {
  name: '${deployment().name}-dapr-entrycam'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    url: 'mqtt://${Mosquitto.outputs.fqdn}:1883'
    topic: 'trafficcontrol/entrycam'
    consumerID: '{uuid}'
  }
}

module daprExitcam 'dapr/exitcam.bicep' = {
  name: '${deployment().name}-dapr-exitcam'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    url: 'mqtt://${Mosquitto.outputs.fqdn}:1883'
    topic: 'trafficcontrol/exitcam'
    consumerID: '{uuid}'
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
    Mosquitto
  ]
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    registry: registry
    registryUsername: registryUsername
    registryPassword: registryPassword
  }
}

module MailDev 'apps/MailDev.bicep' = {
  name: '${deployment().name}-maildev'
  dependsOn: [
    daprEmail
  ]
  params: {
    location:location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
  }
}

module Mosquitto 'apps/mosquitto.bicep' = {
  name: '${deployment().name}-mosquitto'
  params: {
    location:location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    registry: registry
    registryUsername: registryUsername
    registryPassword: registryPassword
  }
}
