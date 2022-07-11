param location string

param containerAppsEnvironmentId string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'FineCollection-svc'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: 'finecollection-svc'
          image: 'traffic/finecollection-svc:1'
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
    }
  }
}
