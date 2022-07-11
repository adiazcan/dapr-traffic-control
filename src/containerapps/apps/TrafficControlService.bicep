param location string

param containerAppsEnvironmentId string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'TrafficControl-svc'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: 'trafficcontrol-svc'
          image: 'traffic/trafficcontrol-svc:1'
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
    }
  }
}
