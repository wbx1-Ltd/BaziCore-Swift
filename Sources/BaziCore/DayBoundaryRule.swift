/// Where the day pillar (日柱) changes over.
public enum DayBoundaryRule: String, CaseIterable, Codable, Hashable, Sendable {
    /// The day pillar changes at local civil midnight (00:00).
    case civilMidnight
    /// The day pillar changes at the start of the 子 hour (23:00).
    case ziHourStart
}
