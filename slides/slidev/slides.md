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

Switch to Claude Code, started with its shell and web tools turned off:

  claude --disallowedTools "Bash PowerShell WebFetch WebSearch"

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
layout: "section"
kicker: ""
---

# APIs vs. CLIs vs. MCP

<!--
Cover the ways to expose your services, and be honest about when MCP isn't the answer.
-->

---
layout: "section"
kicker: ""
---

# The concept: a time and timezone server

---
layout: "default"
---

# Three primitives, one domain

| Primitive | In the time server |
| --- | --- |
| **Tools** | Get the current time; convert between zones |
| **Resource** | The list of supported zones |
| **Prompt** | Find a meeting time across zones |

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

AddMcpServer() is like AddControllers(). A tool class with [McpServerTool] methods is like
a controller and its actions. Point at the LogToStandardErrorThreshold line: "remember this."
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
layout: "section"
kicker: ""
---

# Run it in MCP Inspector

<!--
- Show the raw JSON-RPC. This is what the model sees.
- Show the stdout gotcha with the stdio transport.
- Write error messages that help the model retry.

Demo: src/demo03 into src/demo04. Run the Inspector from inside the project folder.
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
layout: "section"
kicker: ""
---

# Go remote

<!--
Switch to the HTTP transport, show it deployed to Azure, and connect Codex and Copilot.
Same server, every client.

Demo: src/demo05
-->

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
