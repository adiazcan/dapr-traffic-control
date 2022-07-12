param containerAppsEnvironmentName string

param url string
param topic string
param consumerID string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName

  resource daprComponent 'daprComponents@2022-03-01' = {
    name: 'exitcam'
    properties: {
      componentType: 'bindings.mqtt'
      version: 'v1'
      metadata: [
        {
          name: 'url'
          value: url
        }
        {
          name: 'topic'
          value: topic
        }        
        {
          name: 'consumerID'
          value: consumerID
        }        
      ]
      scopes: [
        'trafficcontrol-svc'
      ]
    }
  }
}

output daprExitCamName string = containerAppsEnvironment::daprComponent.name
