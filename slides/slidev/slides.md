---
theme: default
title: Building MCP Servers in .NET
info: |
  ## Building MCP Servers in .NET
  Kevin Griffin - Microsoft MVP - TechBash 2026
author: Kevin Griffin
keywords: dotnet,mcp,model-context-protocol,ai
class: text-left
highlighter: shiki
lineNumbers: false
drawings:
  persist: false
transition: none
mdc: true
fonts:
  sans: Source Sans 3
  mono: JetBrains Mono
  provider: none
layout: "blank"
---

<!-- intentionally blank -->

<!--
[holding] BLANK

On screen while the room settles. Advance once into the cold open.
-->

---
layout: "statement"
---

What time is it in Tokyo right now?

<!--
[COLD OPEN]

Switch to Claude Code, started from the repo root with its shell, web, and subagent tools
off and no MCP servers loaded (the Docker MCP gateway has a time tool):

  claude --strict-mcp-config --mcp-config .mcp.json --disallowedTools "Bash PowerShell WebFetch WebSearch Agent"

Tell the room you turned them off. Ask the question and let it fail or hedge.
We come back to this in section 8.
-->

---
layout: "statement"
---

I built my first MCP server in C#. It took about 30 minutes.

<Caption>

And it just worked with Claude, GitHub Copilot, and every other MCP client I threw at it.

</Caption>

<!--
The skeptic story: two decades of custom connectors and one-off APIs, then the first MCP
server built in 30 minutes.
-->

---
layout: "cover"
variant: "title"
image: "/kevin-griffin.png"
---

# Building MCP Servers in .NET

- Kevin Griffin
- Microsoft MVP

---
layout: "cover"
variant: "bio"
image: "/kevin-griffin.png"
---

# Kevin Griffin

- Independent Consultant
- CTO, Shows On Sale
- Microsoft MVP
- consultwithgriff.com  ·  @1kevgriff

<!--
Keep the bio quick.
-->

---
layout: "section"
kicker: ""
---

# How AI harnesses use tools

---
layout: "statement"
---

The model never runs your code. The harness does.

<Caption>

Claude Code, Copilot and Codex are harnesses: the program around the model that runs the tools it asks for.

</Caption>

<!--
Define "harness" once and use the word for the rest of the talk.
-->

---
layout: "default"
---

# The tool loop

<Cards :cols="4">

<Card n="01" title="The model sees the tool descriptions" v-click></Card>
<Card n="02" title="It picks a tool" v-click></Card>
<Card n="03" title="The harness calls it" v-click></Card>
<Card n="04" title="The result goes back to the model" accent v-click></Card>

</Cards>

<!--
Walk through the loop: the model sees tool descriptions, picks one, the harness calls it,
and the result goes back to the model.
-->

---
layout: "code"
codeSize: "15"
---

# This is all the model knows about your tool

```json
{
  "name": "get_current_time",
  "description": "Gets the current date and time in a time zone.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "timeZone": {
        "description": "IANA time zone ID, for example 'Asia/Tokyo' or 'America/New_York'.",
        "type": "string"
      }
    },
    "required": ["timeZone"]
  },
  "annotations": { "readOnlyHint": true }
}
```

<!--
The real tools/list entry from the server we build today (src/demo02 onward).

A name, a sentence, and a schema. No source code, no docs site. If the description is vague,
the model guesses. That's why section 6 spends time on [Description].
-->

---
layout: "panels"
---

# The model asks. The server answers.

<PanelRow :cols="2" size="12.5" arrow>

<Panel caption="tools/call">

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "convert_time",
    "arguments": {
      "dateTime": "2026-10-15T10:20:00",
      "fromTimeZone": "America/New_York",
      "toTimeZone": "Asia/Tokyo"
    }
  }
}
```

</Panel>

<Panel caption="result" dark>

```json
{
  "structuredContent": {
    "timeZone": "Asia/Tokyo",
    "localTime": "2026-10-15T23:20:00+09:00",
    "dayOfWeek": "Thursday",
    "isDaylightSavingTime": false
  }
}
```

</Panel>

</PanelRow>

<Caption>

This talk starts at 11:20 PM in Tokyo.

</Caption>

<!--
A real call and result from src/demo04 (the result is trimmed to structuredContent; the
response also carries the same JSON as text content for older clients).

JSON-RPC 2.0. That's the whole wire format.
-->

---
layout: "statement"
---

MCP standardizes the server end of that loop. Write it once, and every client can call it.

<!--
Before MCP, every harness had its own way to plug in tools. Now the server side is a protocol.
-->

---
layout: "section"
kicker: ""
---

# APIs vs. CLIs vs. MCP

<!--
Cover the ways to expose your services, and be honest about when MCP isn't the answer.
-->

---
layout: "default"
---

# Three ways to put your service in front of a model

| | The agent uses it through | Best when |
| --- | --- | --- |
| **Your REST API** | a generic HTTP tool, plus docs for the endpoints | the client can already make HTTP calls and the API is well documented |
| **A CLI** | a shell | the agent has a shell and a good CLI already exists |
| **An MCP server** | tools the client discovers, with names, descriptions and schemas | several clients need it, there's no shell, or you want typed results |

---
layout: "default"
---

# When MCP isn't the answer

<Cards :cols="3">

<Card n="01" title="There's already a good CLI" v-click>

…and the agent has a shell. Claude Code could have answered the cold open with `date`. I turned that off.

</Card>

<Card n="02" title="One client, one script" v-click>

A tool built into that one harness is less to build and less to run.

</Card>

<Card n="03" title="Every tool costs context" accent v-click>

Tool definitions take up the model's context. Fifty tools spend it before any work starts.

</Card>

</Cards>

<!--
Be honest here; it buys credibility for the rest of the talk.

Card 1 is the callback to the cold open: with a shell, `TZ=Asia/Tokyo date` would have
answered it. That's why the shell was off.
-->

---
layout: "statement"
---

Reach for MCP when more than one client needs it, or when there's no shell to fall back on.

---
layout: "section"
kicker: ""
---

# The concept: a time and timezone server

<!--
Small enough to build live, and it covers all three primitives in one domain.
-->

---
layout: "default"
---

# Three primitives, one domain

| Primitive | Who decides to use it | In the time server |
| --- | --- | --- |
| **Tools** | the model | Get the current time; convert between zones |
| **Resource** | the application | The list of supported zones |
| **Prompt** | the user | Find a meeting time across zones |

<!--
From the MCP spec: tools are model-controlled, resources are application-driven, prompts
are user-controlled. In Claude Code, a prompt shows up as a slash command.
-->

---
layout: "section"
kicker: ""
---

# `dotnet new`

<!--
Create the project from the MCP server template and tour what it generated.
Map it to familiar ASP.NET Core and DI patterns.

Demo: src/demo01
-->

---
layout: "code"
codeSize: "15"
---

```text
$ dotnet new install Microsoft.McpServer.ProjectTemplates
$ dotnet new mcpserver -n TimeServer
```

```csharp
var builder = Host.CreateApplicationBuilder(args);

// Configure all logs to go to stderr (stdout is used for the MCP protocol messages).
builder.Logging.AddConsole(o => o.LogToStandardErrorThreshold = LogLevel.Trace);

// Add the MCP services: the transport to use (stdio) and the tools to register.
builder.Services
    .AddMcpServer()
    .WithStdioServerTransport()
    .WithTools<RandomNumberTools>();

await builder.Build().RunAsync();
```

<!--
From src/demo01/Program.cs, exactly as the template generates it (usings omitted).

Point at the LogToStandardErrorThreshold line: "remember this." It pays off in section 7.
-->

---
layout: "default"
---

# You already know this shape

| ASP.NET Core | MCP C# SDK |
| --- | --- |
| `AddControllers()` | `AddMcpServer()` |
| a controller class | a tool class, registered with `WithTools<T>()` |
| an action method | a method with `[McpServerTool]` |
| model binding | tool arguments, bound from JSON |
| OpenAPI descriptions | `[Description]`, published as the input schema |
| constructor injection | constructor injection |

<!--
The last row is the point: nothing new to learn about DI.
-->

---
layout: "section"
kicker: ""
---

# Build it out

<!--
- Inject TimeProvider: the DI point and the testability point together.
- Write the [Description] text, since that's what the model reads.
- Return structured output.
- Add the resource and the prompt.

Demo: src/demo02, then src/demo03
-->

---
layout: "code"
codeSize: "14"
---

```csharp
internal class TimeTools(TimeProvider timeProvider)
{
    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Gets the current date and time in a time zone.")]
    public ZonedTime GetCurrentTime(
        [Description("IANA time zone ID, for example 'Asia/Tokyo' or 'America/New_York'.")]
        string timeZone)
    {
        var zone = TimeZoneInfo.FindSystemTimeZoneById(timeZone);
        return ZonedTime.From(timeProvider.GetUtcNow(), zone);
    }
}
```

```csharp
builder.Services.AddSingleton(TimeProvider.System);
```

<!--
The first tool, from src/demo02 (the attribute is wrapped onto its own line for the slide).

TimeProvider comes in through the constructor: same DI as ASP.NET Core, and tests can swap in
a FakeTimeProvider.
-->

---
layout: "panels"
---

# `[Description]` is the documentation the model reads

<PanelRow :cols="1" size="11.5">

<Panel caption="what you write">

```csharp
[Description("Gets the current date and time in a time zone.")]
public ZonedTime GetCurrentTime(
    [Description("IANA time zone ID, for example 'Asia/Tokyo' or 'America/New_York'.")]
    string timeZone)
```

</Panel>

<Panel caption="what the model reads" dark>

```json
"description": "Gets the current date and time in a time zone.",
"inputSchema": {
  "type": "object",
  "properties": {
    "timeZone": {
      "description": "IANA time zone ID, for example 'Asia/Tokyo' or 'America/New_York'.",
      "type": "string"
    }
  },
  "required": ["timeZone"]
}
```

</Panel>

</PanelRow>

<!--
Say what format you want, and give an example. "Asia/Tokyo" does more work than any adjective.
-->

---
layout: "panels"
---

# Return a record, not a sentence

<PanelRow :cols="2" size="11" arrow>

<Panel caption="what you write">

```csharp
public record ZonedTime(
    string TimeZone,
    DateTimeOffset LocalTime,
    string DayOfWeek,
    bool IsDaylightSavingTime);
```

</Panel>

<Panel caption="what the client gets" dark>

```json
"outputSchema": {
  "type": "object",
  "properties": {
    "timeZone": { "type": "string" },
    "localTime": { "type": "string", "format": "date-time" },
    "dayOfWeek": { "type": "string" },
    "isDaylightSavingTime": { "type": "boolean" }
  }
}
```

</Panel>

</PanelRow>

<Caption>

`UseStructuredContent = true` publishes the output schema with the tool, and every result comes back as `structuredContent`.

</Caption>

<!--
The day of week is there on purpose: models often get it wrong when they work it out from a date.
-->

---
layout: "panels"
---

# Why `dateTime` is a string

<PanelRow :cols="2" size="13.5" arrow>

<Panel caption="the model sent">

```text
convert_time
  dateTime      2026-10-15T10:20:00-04:00
  fromTimeZone  America/New_York
  toTimeZone    Asia/Tokyo
```

</Panel>

<Panel caption="a DateTime parameter returned" dark>

```text
2026-10-16T03:20:00+09:00   Friday
```

</Panel>

</PanelRow>

<Caption gold>

The right answer is 11:20 PM Thursday.

</Caption>

<Caption>

A `DateTime` parameter advertises `format: date-time`, which invites an offset. .NET then converts the value to the server's clock, and this server ran in UTC. A string with one exact format can't be misread.

</Caption>

<!--
Found while building the demos, on a server running in UTC.

On a laptop in Eastern time the same call happens to come out right, because the offset matches
the machine's zone. It breaks once the server lives somewhere else, like the cloud.
-->

---
layout: "code"
codeSize: "14"
---

```csharp
[McpServerResource(UriTemplate = "time://zones", MimeType = "text/plain")]
[Description("Every IANA time zone ID this server accepts, one per line.")]
public static string SupportedTimeZones() =>
    string.Join('\n', TimeZoneInfo.GetSystemTimeZones()
        .Select(ToIanaId).Distinct().Order());
```

```csharp
[McpServerPrompt]
[Description("Finds a meeting time that works for people in several time zones.")]
public static string FindMeetingTime(string timeZones, string duration = "30 minutes") =>
    $"""
    Find a meeting time in the next five business days. The meeting lasts {duration},
    and the participants are in these time zones: {timeZones}.
    Use the get_current_time tool ... and the convert_time tool ...
    """;
```

<!--
From src/demo03, trimmed for the slide: the parameter descriptions and the full prompt text are
in the code.

The resource converts Windows zone IDs to IANA, so the list is the same on every OS.
-->

---
layout: "section"
kicker: ""
---

# Run it in MCP Inspector

<!--
- Show the raw JSON-RPC. This is what the model sees.
- Show the stdout gotcha with the stdio transport.
- Write error messages that help the model retry.

Demo: src/demo03 into src/demo04. Set the Inspector's Request Timeout to about 10 seconds first.
-->

---
layout: "code"
codeSize: "17"
---

```text
$ cd src/demo03
$ npx @modelcontextprotocol/inspector dotnet run
```

<Caption>

Run it from inside the project folder: the Inspector swallows a `--project` flag passed after `dotnet run`.

</Caption>

---
layout: "statement"
---

On stdio, stdout is the protocol.

<Caption>

Anything else your server writes there lands in the client's JSON-RPC stream.

</Caption>

---
layout: "code"
codeSize: "13.5"
---

# One `Console.Write`, one lost response

```text
stdout
──────
Looking up Asia/Tokyo... {"result":{"content":[...]},"id":2,"jsonrpc":"2.0"}
```

```text
MCP Inspector
─────────────
Request timed out after 1m00s (tools/call).
1 request is unanswered: tools/call (sent 1m00s ago).
```

<Caption>

The client silently skips a whole stray line. A partial line sticks to the front of the next message, so the response gets thrown away with it.

</Caption>

<!--
The planted bug in src/demo02 and demo03: Console.Write with no newline.

The fix: inject ILogger<TimeTools>. It goes to stderr because of the template line from
section 5.
-->

---
layout: "reveal"
codeSize: "14"
---

# What the model sees when the zone is wrong

```text
An error occurred invoking 'get_current_time'.
```

<Caption>

The real `TimeZoneNotFoundException` went to stderr. The model never sees it.

</Caption>

<!--
[SETUP] Called with "Tokyo". This is everything the model gets to work with.
-->

---
layout: "reveal"
codeSize: "14"
---

# What the model sees when the zone is wrong

```text
An error occurred invoking 'get_current_time': Unknown time zone 'Tokyo'.
Use an IANA time zone ID such as 'Asia/Tokyo' or 'America/New_York'.
The time://zones resource lists every supported ID.
```

<Caption>

Only `McpException` messages reach the model. Everything else is hidden, so internals don't leak.

</Caption>

<!--
[REVEAL] Same call after the fix in src/demo04. The message is wrapped onto three lines for
the slide.
-->

---
layout: "code"
codeSize: "14.5"
---

```csharp
// The model reads these error messages, so tell it how to fix the call.
private static TimeZoneInfo FindTimeZone(string timeZone) =>
    TimeZoneInfo.TryFindSystemTimeZoneById(timeZone, out var zone)
        ? zone
        : throw new McpException(
            $"Unknown time zone '{timeZone}'. Use an IANA time zone ID such as " +
            "'Asia/Tokyo' or 'America/New_York'. " +
            "The time://zones resource lists every supported ID.");
```

<!--
From src/demo04. ParseWallClock does the same for dates.
-->

---
layout: "section"
kicker: ""
---

# Add it to Claude Code

<!--
Re-ask the Tokyo question for the payoff.

Demo: src/demo04
-->

---
layout: "code"
codeSize: "17"
---

```text
$ claude mcp add time -- dotnet run --project ./src/demo04
```

<Caption>

Restart Claude Code with the same flags, and run `/mcp` to confirm it's connected.

</Caption>

---
layout: "statement"
---

What time is it in Tokyo right now?

<!--
[PAYOFF] Same question, same restrictions, one MCP server. Then run the prompt as a slash
command: /mcp__time__find_meeting_time
-->

---
layout: "section"
kicker: ""
---

# Go remote

<!--
Switch to the HTTP transport, run it on localhost, and connect Codex and Copilot.
Same server, every client.

Demo: src/demo05
-->

---
layout: "panels"
---

# Same tools. Different transport.

<PanelRow :cols="2" size="11.5" arrow>

<Panel caption="stdio">

```csharp
var builder = Host.CreateApplicationBuilder(args);

builder.Services
    .AddMcpServer()
    .WithStdioServerTransport()
    .WithTools<TimeTools>()
    .WithResources<TimeZoneResources>()
    .WithPrompts<MeetingPrompts>();

await builder.Build().RunAsync();
```

</Panel>

<Panel caption="http" dark>

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddMcpServer()
    .WithHttpTransport(o => o.Stateless = true)
    .WithTools<TimeTools>()
    .WithResources<TimeZoneResources>()
    .WithPrompts<MeetingPrompts>();

var app = builder.Build();
app.MapMcp();
app.Run();
```

</Panel>

</PanelRow>

<Caption>

`Tools/`, `Resources/` and `Prompts/` are byte-for-byte the same in demo04 and demo05.

</Caption>

<!--
The stderr logging line is gone too: stdout isn't the protocol anymore.
-->

---
layout: "panels"
---

# Same server, every client

<PanelRow :cols="1" size="15">

<Panel caption="claude code">

```text
$ claude mcp add --transport http time http://localhost:6233/
```

</Panel>

<Panel caption="vs code · .vscode/mcp.json">

```json
{
  "servers": {
    "time": { "type": "http", "url": "http://localhost:6233/" }
  }
}
```

</Panel>

</PanelRow>

<!--
Codex is configured ahead of time with the same URL. Ask the same question in all three.
-->

---
layout: "statement"
---

Stateless means any instance can answer any request.

<Caption>

No session to pin to one server, so you can scale it out without sticky sessions.

</Caption>

---
layout: "statement"
---

This server has no authentication. It's a read-only clock. Yours isn't.

<Caption>

Securing MCP in .NET: J. Tower, “The S in MCP is for Security”, Friday at 10:15 AM.

</Caption>

---
layout: "roadmap"
panelTitle: "The repeatable recipe"
---

1. Scaffold
2. Inject dependencies
3. Write descriptions
4. Return structured output
5. Inspect
6. Write error messages the model can act on
7. Connect a client
8. Go HTTP

<!--
The folder sequence in src/ is the recipe. Share the repo link, then take questions.
-->

---
layout: "section"
kicker: ""
---

# Questions?

---
layout: "cover"
variant: "thanks"
image: "/kevin-griffin.png"
---

# Let's keep talking.

- consultwithgriff.com
- github.com/1kevgriff/building-mcp-servers-in-dotnet
- X · LinkedIn · GitHub — @1kevgriff
- Bluesky — @consultwithgriff.com

<img src="/repo-qr.svg" class="repo-qr" alt="QR code linking to the repository" />
