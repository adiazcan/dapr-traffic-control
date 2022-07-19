using Microsoft.Azure.Devices.Client;

namespace Simulation.Proxies;

public class AzureTrafficControlService : ITrafficControlService
{        
    private readonly DeviceClient client;
    private readonly string iotConnectionString = "HostName=iothub-pw7tjgsfkhl5y.azure-devices.net;DeviceId=simulation;SharedAccessKey=Ya26eSAD6qS55MSSlL3Jf6pm+7TzFSs8LxX4NqzamVE=";

    public AzureTrafficControlService()
    {
        client = DeviceClient.CreateFromConnectionString(iotConnectionString, TransportType.Mqtt);
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
