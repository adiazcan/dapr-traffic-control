param containerAppsEnvironmentName string

param connectionString string
param consumerGroup string
param storageAccountName string
param storageAccountKey string
param storageContainerName string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName

  resource daprComponent 'daprComponents@2022-03-01' = {
    name: 'entrycam'
    properties: {
      componentType: 'bindings.azure.eventhubs'
      version: 'v1'
      metadata: [
        {
          name: 'connectionString'
          value: connectionString
        }
        {
          name: 'consumerGroup'
          value: consumerGroup
        }   
        {
          name: 'storageAccountName'
          value: storageAccountName
        }     
        {
          name: 'storageAccountKey'
          value: storageAccountKey
        }
        {
          name: 'storageContainerName'
          value: storageContainerName
        }
      ]
      scopes: [
        'trafficcontrol-svc'
      ]
    }
  }
}

output daprEntryCamName string = containerAppsEnvironment::daprComponent.name

// apiVersion: dapr.io/v1alpha1
// kind: Component
// metadata:
//   name: entrycam
// spec:
//   type: bindings.azure.eventhubs
//   version: v1
//   metadata:
//   - name: connectionString
//     value: "Endpoint=sb://ehn-dapr-ussc-demo-trafficcontrol.servicebus.windows.net/;SharedAccessKeyName=listen;SharedAccessKey=IQrpNCFakekeykn5xkSVyn5y4uZCGerc=;EntityPath=entrycam"
//   - name: consumerGroup
//     value: "trafficcontrolservice"
//   - name: storageAccountName
//     value: "sadaprusscdemo"
//   - name: storageAccountKey
//     value: "IKJgQ4KAFakekeyhAmi4zSz2ehm1btpQXZ+l68ol7wJmg8TA0ClQChRK7sWnvMEVexgg=="
//   - name: storageContainerName
//     value: "trafficcontrol-entrycam"
// scopes:
// - trafficcontrolservice
