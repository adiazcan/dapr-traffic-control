using Microsoft.Azure.Devices.Client;

namespace Simulation.Proxies;

public class AzureTrafficControlService : ITrafficControlService
{        
    private readonly DeviceClient client;

    public AzureTrafficControlService()
    {
        client = DeviceClient.CreateFromConnectionString("HostName=iothub-dapr-ussc-demo.azure-devices.net;DeviceId=simulation;SharedAccessKey=/cRA4cYbcyC7FakekeyNV6CrfugBe8Ka2z2m8=", TransportType.Mqtt);
    }

    public Task SendVehicleEntryAsync(VehicleRegistered vehicleRegistered)
    {
        var eventJson = JsonSerializer.Serialize(vehicleRegistered);
        var message = new Message(Encoding.UTF8.GetBytes(eventJson));
        message.Properties.Add("trafficcontrol", "entrycam");
        return client.SendEventAsync(message);
    }

    public Task SendVehicleExitAsync(VehicleRegistered vehicleRegistered)
    {
        var eventJson = JsonSerializer.Serialize(vehicleRegistered);
        var message = new Message(Encoding.UTF8.GetBytes(eventJson));
        message.Properties.Add("trafficcontrol", "exitcam");
        return client.SendEventAsync(message);
    }
}
