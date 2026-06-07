/// Where the year pillar (年柱) changes over; the rule is explicit and travels in the trace.
public enum YearBoundaryRule: String, CaseIterable, Codable, Hashable, Sendable {
    /// The year pillar changes at the exact 立春 (Start of Spring) instant. Professional default.
    case liChunExact
    /// The year pillar changes at the lunar new year. Compatibility mode; needs a lunar provider.
    case lunarNewYear
}
