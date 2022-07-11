// apiVersion: dapr.io/v1alpha1
// kind: Component
// metadata:
//   name: sendmail
//   namespace: dapr-trafficcontrol
// spec:
//   type: bindings.smtp
//   version: v1
//   metadata:
//   - name: host
//     value: localhost
//   - name: port
//     value: 4025
//   - name: user
//     secretKeyRef:
//       name: smtp.user
//       key: smtp.user
//   - name: password
//     secretKeyRef:
//       name: smtp.password
//       key: smtp.password
//   - name: skipTLSVerify
//     value: true
// auth:
//   secretStore: trafficcontrol-secrets
// scopes:
//   - finecollectionservice

param containerAppsEnvironmentName string

param host string
param port string
param smtpuser string
@secure()
param smtppassword string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName

  resource daprComponent 'daprComponents@2022-03-01' = {
    name: 'sendmail'
    properties: {
      componentType: 'bindings.smtp'
      version: 'v1'
      metadata: [
        {
          name: 'host'
          value: host
        }
        {
          name: 'port'
          value: port
        }        
        {
          name: 'user'
          value: smtpuser
        }        
        {
          name: 'password'
          value: smtppassword //llevar a secret
        }      
      ]
      scopes: [
        'maildev'
      ]
    }
  }
}

output daprEmailName string = containerAppsEnvironment::daprComponent.name
