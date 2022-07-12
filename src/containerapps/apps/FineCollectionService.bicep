param location string

param containerAppsEnvironmentId string
param registry string
param registryUsername string
@secure()
param registryPassword string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'finecollection-svc'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: 'finecollection-svc'
          image: 'mycontapp.azurecr.io/traffic/finecollection-svc:1'
          env: [
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://*:6001'
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
        appId: 'finecollection-svc'
        appPort: 6001
      }
      ingress: {
        external: true
        targetPort: 6001
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
