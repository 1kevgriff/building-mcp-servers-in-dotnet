# building-mcp-servers-in-dotnet
Talk: Building MCP Servers in .NET

- **Speaker:** Kevin Griffin
- **Event:** [TechBash 2026](https://techbash.com/sessions): Thursday, October 15, 2026, 10:20–11:20 AM, Salons E/F
- **Format:** 60 Minute Session · AI · .NET
- **Outline:** [OUTLINE.md](OUTLINE.md)

## Abstract

I've been building integrations between services for the better part of two decades. Custom connectors, one-off APIs, the whole nine yards. So when the Model Context Protocol showed up and said "what if there was a standard way to connect AI clients to your tools and data?" I was skeptical. Then I built my first MCP server in C#. It took about 30 minutes. And it just worked with Claude, GitHub Copilot, and every other MCP client I threw at it.

In this session, we'll go from dotnet new to a working MCP server, live. You'll learn the building blocks (tools, resources, and prompts) and see how the C# SDK maps them to patterns you already know from ASP.NET Core and dependency injection. We'll cover real-world design decisions like choosing transports, structuring tool output so models can actually use it, and getting the whole thing deployed to Azure. Walk out with a repeatable recipe for making your .NET services accessible to any MCP-compatible AI client.
