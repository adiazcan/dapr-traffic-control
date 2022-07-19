using Microsoft.Azure.Devices.Client;

namespace Simulation.Proxies;

public class AzureTrafficControlService : ITrafficControlService
{        
    private readonly DeviceClient client;

    public AzureTrafficControlService()
    {
        client = DeviceClient.CreateFromConnectionString("HostName=iothub-pw7tjgsfkhl5y.azure-devices.net;DeviceId=simulation;SharedAccessKey=r+Q1QvkENi9LyRG/BEMh/aW9kwpyc9RM78IHykVgaLY=", TransportType.Mqtt);
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
