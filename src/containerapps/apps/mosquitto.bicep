param location string

param containerAppsEnvironmentId string
param registry string
param registryUsername string
@secure()
param registryPassword string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'mosquitto'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: 'mosquitto'
          image: 'mycontapp.azurecr.io/traffic/mosquitto:1.0'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: true
        targetPort: 1883 //9001
        allowInsecure: true
      }
      secrets: [
        {
          name: 'container-registry-password'
          value: registryPassword
        }      
      ]
      registries: [
        {
          server:registry
          username:registryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]    
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
