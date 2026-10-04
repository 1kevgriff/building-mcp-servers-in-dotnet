using System.ComponentModel;
using System.Globalization;
using Microsoft.Extensions.Logging;
using ModelContextProtocol;
using ModelContextProtocol.Server;

/// <summary>
/// Tools for reading the current time and converting between time zones.
/// </summary>
internal class TimeTools(TimeProvider timeProvider, ILogger<TimeTools> logger)
{
    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Gets the current date and time in a time zone.")]
    public ZonedTime GetCurrentTime(
        [Description("IANA time zone ID, for example 'Asia/Tokyo' or 'America/New_York'.")] string timeZone)
    {
        logger.LogInformation("Looking up the current time in {TimeZone}", timeZone);

        var zone = FindTimeZone(timeZone);
        return ZonedTime.From(timeProvider.GetUtcNow(), zone);
    }

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Converts a wall-clock date and time from one time zone to another.")]
    public ZonedTime ConvertTime(
        [Description("Date and time in the source time zone, as ISO 8601 without an offset, for example '2026-10-15T10:20:00'.")] string dateTime,
        [Description("IANA time zone ID the date and time is in, for example 'America/New_York'.")] string fromTimeZone,
        [Description("IANA time zone ID to convert to, for example 'Asia/Tokyo'.")] string toTimeZone)
    {
        var wallClock = ParseWallClock(dateTime);
        var from = FindTimeZone(fromTimeZone);
        var to = FindTimeZone(toTimeZone);

        var instant = new DateTimeOffset(wallClock, from.GetUtcOffset(wallClock));
        return ZonedTime.From(instant, to);
    }

    // The model reads these error messages, so tell it how to fix the call.
    private static DateTime ParseWallClock(string dateTime) =>
        DateTime.TryParseExact(dateTime, "s", CultureInfo.InvariantCulture, DateTimeStyles.None, out var wallClock)
            ? wallClock
            : throw new McpException(
                $"Couldn't read '{dateTime}' as a date and time. Use ISO 8601 without an offset, such as '2026-10-15T10:20:00'.");

    private static TimeZoneInfo FindTimeZone(string timeZone) =>
        TimeZoneInfo.TryFindSystemTimeZoneById(timeZone, out var zone)
            ? zone
            : throw new McpException(
                $"Unknown time zone '{timeZone}'. Use an IANA time zone ID such as 'Asia/Tokyo' or 'America/New_York'. " +
                "The time://zones resource lists every supported ID.");
}

/// <summary>
/// A moment in time as seen in a specific time zone.
/// </summary>
public record ZonedTime(string TimeZone, DateTimeOffset LocalTime, string DayOfWeek, bool IsDaylightSavingTime)
{
    public static ZonedTime From(DateTimeOffset instant, TimeZoneInfo zone)
    {
        var local = TimeZoneInfo.ConvertTime(instant, zone);
        return new(zone.Id, local, local.DayOfWeek.ToString(), zone.IsDaylightSavingTime(local));
    }
}
