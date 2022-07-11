param location string = resourceGroup().location
param uniqueSeed string = '${resourceGroup().id}-${deployment().name}'

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

////////////////////////////////////////////////////////////////////////////////
// Container apps
////////////////////////////////////////////////////////////////////////////////

module VehicleRegistrationService 'apps/VehicleRegistrationService.bicep' = {
  name: '${deployment().name}-app-vehicleregistration-svc'
  dependsOn: [
    daprPubSub
    daprStateStore
  ]
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
  }
}

module FineCollectionService 'apps/FineCollectionService.bicep' = {
  name: '${deployment().name}-app-finecollection-svc'
  dependsOn: [
    daprPubSub
    daprStateStore
  ]
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
  }
}

module TrafficControlService 'apps/TrafficControlService.bicep' = {
  name: '${deployment().name}-app-trafficcontrol-svc'
  dependsOn: [
    daprPubSub
    daprStateStore
  ]
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
  }
}

module MailDev 'apps/MailDev.bicep' = {
  name: '${deployment().name}-maildev'
  dependsOn: [
    daprPubSub
  ]
  params: {
    location:location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
  }
}
