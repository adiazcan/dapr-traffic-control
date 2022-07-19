var environment = "self-hosted";
int lanes = 3;

if (args.Length > 0)
{
    environment = args[0];
    lanes = 1;
}

CameraSimulation[] cameras = new CameraSimulation[lanes];
for (var i = 0; i < lanes; i++)
{
    int camNumber = i + 1;
    ITrafficControlService trafficControlService;
    
    Console.WriteLine($"Connecting to {environment}");

    if (environment.Equals("self-hosted")) 
    {
        trafficControlService = await MqttTrafficControlService.CreateAsync(camNumber);
    }
    else 
    {
        trafficControlService = new AzureTrafficControlService();
    }
    cameras[i] = new CameraSimulation(camNumber, trafficControlService);
}
Parallel.ForEach(cameras, cam => cam.Start());

Task.Run(() => Thread.Sleep(Timeout.Infinite)).Wait();