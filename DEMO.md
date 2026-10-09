# Live Demo: Time and Timezone Server

The talk has one demo, built up over several sections. Each folder under `src/` is a complete, runnable snapshot of the server at the end of a step. If a step breaks on stage, open the next folder and keep going.

| Folder | State | Outline section |
| --- | --- | --- |
| [`src/demo01`](src/demo01) | `dotnet new mcpserver` output, untouched | §5 `dotnet new` |
| [`src/demo02`](src/demo02) | Time tools, with two planted bugs | §6 Build it out |
| [`src/demo03`](src/demo03) | Adds the resource and the prompt (bugs still planted) | §6 Build it out |
| [`src/demo04`](src/demo04) | Bugs fixed: logging and error messages | §7 MCP Inspector, §8 Claude Code |
| [`src/demo05`](src/demo05) | HTTP transport on localhost | §9 Go remote |

Built against the .NET 10 SDK, `Microsoft.McpServer.ProjectTemplates` 1.2.1, `ModelContextProtocol` 2.1.0, and MCP Inspector 2.9.0.

## Before you go on stage

- Install the template: `dotnet new install Microsoft.McpServer.ProjectTemplates`
- Run `npx @modelcontextprotocol/inspector` once so it's cached.
- In the Inspector's settings, set **Request Timeout** to about 10 seconds. The stdout bug hangs the call, and you don't want to wait a full minute for it.
- Build every demo folder so nothing needs the network: `dotnet build src/demo01` through `src/demo05`.
- Add `http://localhost:6233/` to Codex and Copilot ahead of time.
- Rehearse the cold open. Its result depends on the model.

## Step 1: Cold open (§1)

Start Claude Code with its shell and web tools turned off, and tell the audience you did. Otherwise it just runs `date` and gets the answer right.

```
claude --disallowedTools "Bash PowerShell WebFetch WebSearch"
```

Ask: *"What time is it in Tokyo right now?"* It can only guess or hedge.

## Step 2: Scaffold (§5) → `demo01`

```
dotnet new mcpserver -n TimeServer
```

Tour what it generated:

- `Program.cs` uses the generic host: `AddMcpServer()`, `WithStdioServerTransport()`, `WithTools<RandomNumberTools>()`.
- Map it to ASP.NET Core:
  - `AddMcpServer()` is like `AddControllers()`.
  - A tool class with `[McpServerTool]` methods is like a controller and its actions.
  - Tool parameters bind like model binding, and constructor injection works the same way.
- Point at the `LogToStandardErrorThreshold` line and say "remember this."
- The `.csproj` is set up to pack as a NuGet tool (`PackAsTool`, `PackageType` `McpServer`), so it can ship through NuGet.

## Step 3: Time tools (§6) → `demo02`

- Delete `Tools/RandomNumberTools.cs` and add `Tools/TimeTools.cs`.
- In `Program.cs`, register `TimeProvider.System` and switch to `.WithTools<TimeTools>()`.

Talking points:

- `TimeProvider` comes in through the constructor. It's the same DI as ASP.NET Core, and tests can swap in a `FakeTimeProvider`.
- The `[Description]` text is what the model reads. Ask for IANA IDs and show an example.
- `UseStructuredContent = true` with a record return type gives the client an output schema and a `structuredContent` result. `ReadOnly = true` tells clients the tool changes nothing.
- `dateTime` is a `string`, not a `DateTime`. A `DateTime` parameter advertises `format: date-time`, which invites the model to send an offset, and .NET then quietly shifts the value to the server's clock.

Planted bugs (don't point them out yet):

1. `Console.Write($"Looking up {timeZone}... ");` in `GetCurrentTime`.
2. `TimeZoneInfo.FindSystemTimeZoneById` and `DateTime.ParseExact` exceptions escape the tools.

## Step 4: Resource and prompt (§6) → `demo03`

- Add `Resources/TimeZoneResources.cs`: the `time://zones` resource lists every supported IANA ID. It converts Windows zone IDs, so the list is the same on every OS.
- Add `Prompts/MeetingPrompts.cs`: the `find_meeting_time` prompt takes the participants' zones and a meeting length.
- Register them with `.WithResources<TimeZoneResources>()` and `.WithPrompts<MeetingPrompts>()`.

## Step 5: MCP Inspector (§7) → `demo04`

From the project folder:

```
npx @modelcontextprotocol/inspector dotnet run
```

Run it from inside the folder. The Inspector swallows a `--project` flag passed after `dotnet run`.

1. **Show `tools/list`.** The descriptions and the input and output schemas are exactly what the model reads.
2. **Call `get_current_time` with `Asia/Tokyo`. It hangs until the request times out.** With stdio, stdout *is* the protocol. Clients silently drop a stray line that isn't JSON, so a `Console.WriteLine` just vanishes. A partial line from `Console.Write` sticks to the front of the next JSON-RPC message, so the response gets dropped with it and never arrives.
   - Fix: inject `ILogger<TimeTools>` and log instead. It goes to stderr because of the line from step 2.
3. **Call it again:** a structured result.
4. **Call it with `Tokyo`.** The model gets only `An error occurred invoking 'get_current_time'.` The real exception went to stderr, where the model never sees it.
   - Fix: add `FindTimeZone` and `ParseWallClock`, which throw `McpException` with a message that says how to correct the call. The SDK passes `McpException` messages to the model and hides other exceptions, so internals don't leak.
5. **Call it with `Tokyo` again.** The message now names the right format and points to `time://zones`.
6. **Read `time://zones`** and **get the `find_meeting_time` prompt.**

## Step 6: Claude Code (§8), using `demo04`

```
claude mcp add time -- dotnet run --project /path/to/src/demo04
```

- Restart Claude Code with the same `--disallowedTools` flags, run `/mcp` to confirm the server is connected, and ask the Tokyo question again.
- Run the prompt as a slash command: `/mcp__time__find_meeting_time`. Pass the zones without spaces, for example `America/New_York,Europe/London,Asia/Tokyo`.
- Optional, if it reproduces in rehearsal: ask about a city whose IANA ID isn't obvious, and let the audience watch the model recover from the error message.

## Step 7: Go remote (§9) → `demo05`

What changes:

- `.csproj`: `Microsoft.NET.Sdk.Web` and `ModelContextProtocol.AspNetCore`.
- `Program.cs`: `WebApplication`, `.WithHttpTransport(o => o.Stateless = true)`, and `app.MapMcp()`.
- The stderr logging line is gone, because stdout isn't the protocol anymore.
- `Tools/`, `Resources/`, and `Prompts/` are unchanged. Diff the two folders to prove it.

Then:

- Run it locally with `dotnet run --project src/demo05`. It listens on `http://localhost:6233/`, and `TimeServer.http` sends a raw `tools/call`.
- In Claude Code: `claude mcp add --transport http time-http http://localhost:6233/`
- Ask the same question from Codex and Copilot, which you set up before the talk.
- Stateless mode keeps no per-session state, so any instance can answer any request when you scale it out.
- There's no authentication. That's fine for a read-only time server; J. Tower's "The S in MCP is for Security" (Friday, 10:15 AM) covers securing MCP in .NET.

## Wrap-up (§10)

The folder sequence is the repeatable recipe:

1. Scaffold.
2. Inject dependencies.
3. Write descriptions.
4. Return structured output.
5. Inspect.
6. Write error messages the model can act on.
7. Connect a client.
8. Go HTTP.
