using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = Host.CreateApplicationBuilder(args);

// Configure all logs to go to stderr (stdout is used for the MCP protocol messages).
builder.Logging.AddConsole(o => o.LogToStandardErrorThreshold = LogLevel.Trace);

// Register the clock so tools can depend on it (and tests can swap in a FakeTimeProvider).
builder.Services.AddSingleton(TimeProvider.System);

// Add the MCP services: the transport to use (stdio) and the tools, resources, and prompts to register.
builder.Services
    .AddMcpServer()
    .WithStdioServerTransport()
    .WithTools<TimeTools>()
    .WithResources<TimeZoneResources>()
    .WithPrompts<MeetingPrompts>();

await builder.Build().RunAsync();
