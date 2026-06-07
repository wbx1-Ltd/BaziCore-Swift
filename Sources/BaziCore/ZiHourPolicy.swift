/// How the late-Zi hour (晚子时, 23:00–23:59) maps to the day pillar; the hour branch stays 子.
public enum ZiHourPolicy: String, CaseIterable, Codable, Hashable, Sendable {
    /// 23:00–23:59 belongs to the next day for the day pillar (晚子时归明日). Professional default.
    case lateZiNextDay
    /// 23:00–23:59 keeps the current day for the day pillar (晚子时归当日), still a 子 hour branch.
    case lateZiSameDay
}
