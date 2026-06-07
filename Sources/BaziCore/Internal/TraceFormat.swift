import Foundation

/// Stable, locale-independent formatting for trace detail values.
enum TraceFormat {
    /// ISO-8601 string in UTC, e.g. "2025-02-03T14:10:26Z".
    static func iso(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let c = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = pad(c.year ?? 0, width: 4)
        let month = pad(c.month ?? 1)
        let day = pad(c.day ?? 1)
        let hour = pad(c.hour ?? 0)
        let minute = pad(c.minute ?? 0)
        let second = pad(c.second ?? 0)
        return "\(year)-\(month)-\(day)T\(hour):\(minute):\(second)Z"
    }

    static func localDateTime(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> String {
        "\(pad(year, width: 4))-\(pad(month))-\(pad(day))T\(pad(hour)):\(pad(minute)):\(pad(second))"
    }

    private static func pad(_ value: Int, width: Int = 2) -> String {
        let text = String(value)
        guard text.count < width else { return text }
        return String(repeating: "0", count: width - text.count) + text
    }
}
