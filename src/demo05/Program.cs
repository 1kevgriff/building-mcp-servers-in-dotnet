var builder = WebApplication.CreateBuilder(args);

// Register the clock so tools can depend on it (and tests can swap in a FakeTimeProvider).
builder.Services.AddSingleton(TimeProvider.System);

// Add the MCP services: the transport to use (http) and the tools, resources, and prompts to register.
builder.Services
    .AddMcpServer()
    .WithHttpTransport(options =>
    {
        // Stateless mode is recommended for servers that don't need
        // server-to-client requests like sampling or elicitation.
        // See https://csharp.sdk.modelcontextprotocol.io/concepts/transports/transports.html for details.
        options.Stateless = true;
    })
    .WithTools<TimeTools>()
    .WithResources<TimeZoneResources>()
    .WithPrompts<MeetingPrompts>();

var app = builder.Build();
app.MapMcp();

app.Run();
