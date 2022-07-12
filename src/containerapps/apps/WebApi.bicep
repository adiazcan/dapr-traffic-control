param location string

param containerAppsEnvironmentId string
param registry string
param registryUsername string
@secure()
param registryPassword string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'webapi-svc'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: 'webapi-svc'
          image: 'mycontapp.azurecr.io/traffic/webapi-svc:1'
          env: [
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://*:6002'
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
        appId: 'vehicleregistration-svc'
        appPort: 6002
      }
      ingress: {
        external: false
        targetPort: 6002
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
