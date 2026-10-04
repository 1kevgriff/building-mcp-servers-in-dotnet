using System.ComponentModel;
using ModelContextProtocol.Server;

/// <summary>
/// Reusable prompts that put the time tools to work.
/// </summary>
internal class MeetingPrompts
{
    [McpServerPrompt]
    [Description("Finds a meeting time that works for people in several time zones.")]
    public static string FindMeetingTime(
        [Description("IANA time zone IDs of the participants, separated by commas, for example 'America/New_York, Europe/London, Asia/Tokyo'.")] string timeZones,
        [Description("How long the meeting lasts, for example '30 minutes' or '1 hour'.")] string duration = "30 minutes") =>
        $"""
        Find a meeting time in the next five business days. The meeting lasts {duration}, and the participants are in these time zones: {timeZones}.

        Use the get_current_time tool to learn today's date in each zone, and the convert_time tool to check candidate times.
        Prefer times between 9:00 and 17:00 local time for everyone. If no time fits, pick the one that puts the fewest people outside those hours.

        Show the result as a table with one row per time zone, giving the local day, date, and time.
        """;
}
