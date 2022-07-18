try
{
    Console.WriteLine("INIT Traffic Progam.cs");
    // create web-app
    var builder = WebApplication.CreateBuilder(args);

    builder.Services.AddSingleton<ISpeedingViolationCalculator>(
        new DefaultSpeedingViolationCalculator("A12", 10, 100, 5));

    Console.WriteLine("Added ISpeedingViolationCalculator");

    builder.Services.AddSingleton<IVehicleStateRepository, DaprVehicleStateRepository>();

    Console.WriteLine("Added IVehicleStateRepository");


    var daprHttpPort = Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3600";
    var daprGrpcPort = Environment.GetEnvironmentVariable("DAPR_GRPC_PORT") ?? "60000";
    builder.Services.AddDaprClient(builder => builder
        .UseHttpEndpoint($"http://localhost:{daprHttpPort}")
        .UseGrpcEndpoint($"http://localhost:{daprGrpcPort}"));

    Console.WriteLine("Added DarpClient");

    builder.Services.AddControllers();

    builder.Services.AddActors(options =>
    {
        options.Actors.RegisterActor<VehicleActor>();
    });

    Console.WriteLine("Added Actors");

    var app = builder.Build();

    // configure web-app
    if (app.Environment.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }
    app.UseCloudEvents();

    // configure routing
    app.MapControllers();
    app.MapActorsHandlers();

    // let's go!
    app.Run();    

    Console.WriteLine("App run");
}
catch (System.Exception ex)
{
    Console.WriteLine($"ERROR: {ex.Message}");
    throw;
}

