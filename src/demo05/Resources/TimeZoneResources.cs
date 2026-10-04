using System.ComponentModel;
using ModelContextProtocol.Server;

/// <summary>
/// Read-only data about the time zones this server understands.
/// </summary>
internal class TimeZoneResources
{
    [McpServerResource(UriTemplate = "time://zones", MimeType = "text/plain")]
    [Description("Every IANA time zone ID this server accepts, one per line.")]
    public static string SupportedTimeZones() =>
        string.Join('\n', TimeZoneInfo.GetSystemTimeZones()
            .Select(ToIanaId)
            .Distinct()
            .Order());

    // Windows reports its own zone IDs; convert them so the list is the same on every OS.
    private static string ToIanaId(TimeZoneInfo zone) =>
        !zone.HasIanaId && TimeZoneInfo.TryConvertWindowsIdToIanaId(zone.Id, out var ianaId) ? ianaId : zone.Id;
}
