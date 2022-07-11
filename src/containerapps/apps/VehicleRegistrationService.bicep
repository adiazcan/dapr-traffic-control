param location string

param containerAppsEnvironmentId string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'VehicleRegistration-svc'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: 'vehicleregistration-svc'
          image: 'traffic/vehicleregistration-svc:1'
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
    }
  }
}
