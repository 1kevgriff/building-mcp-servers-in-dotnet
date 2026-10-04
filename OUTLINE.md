# Talk Outline: Building MCP Servers in .NET

Rough outline for the TechBash 2026 session. See the [README](README.md) for the abstract.

The running example is a time and timezone server. It's small enough to build live, and it covers all three MCP primitives in one domain.

## 1. Cold open

- Ask Claude Code: *"What time is it in Tokyo right now?"* Let it fail or hedge.
- Skeptic story: two decades of custom connectors, then the first MCP server built in 30 minutes.
- Keep the bio quick.

## 2. How AI harnesses use tools

Walk through the loop:

1. The model sees the tool descriptions.
2. The model picks a tool.
3. The harness calls it.
4. The result goes back to the model.

## 3. APIs vs. CLIs vs. MCP

- Cover the ways to expose your services to AI clients.
- Be honest about when MCP isn't the answer.

## 4. The concept: a time and timezone server

Introduce the three primitives in the same domain:

| Primitive | In the time server |
| --- | --- |
| Tools | Get the current time; convert between zones |
| Resource | The list of supported zones |
| Prompt | Find a meeting time across zones |

## 5. `dotnet new`

- Create the project from the MCP server template.
- Tour what it generated.
- Map it to familiar ASP.NET Core and DI patterns.

## 6. Build it out

- Inject `TimeProvider`. This makes the DI point and the testability point together.
- Write the `[Description]` text, since that's what the model reads.
- Return structured output.
- Write error messages that help the model retry.
- Add the resource and the prompt.

## 7. Run it in MCP Inspector

- Show the raw JSON-RPC. This is what the model sees.
- Show the stdout gotcha with the stdio transport.

## 8. Add it to Claude Code

- Re-ask the Tokyo question for the payoff.

## 9. Go remote

- Switch to the HTTP transport.
- Show it deployed to Azure.
- Connect Codex and Copilot. Same server, every client.

## 10. Wrap up

- Show the repeatable recipe.
- Share the repo link.
- Take FAQ.
