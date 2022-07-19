param location string

param containerAppsEnvironmentId string
param registry string
param registryUsername string
@secure()
param registryPassword string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'trafficcontrol-svc'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: 'trafficcontrol-svc'
          image: 'mycontapp.azurecr.io/traffic/trafficcontrol-svc:2'
          env: [
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://*:6000'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
    configuration: {
      activeRevisionsMode: 'single'
      dapr: {
        enabled: true
        appId: 'trafficcontrol-svc'
        appPort: 6000
      }
      ingress: {
        external: false
        targetPort: 6000
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
