/// Where the month pillar (月柱) changes over, following the twelve *Jie* (节) solar terms.
public enum MonthBoundaryRule: String, CaseIterable, Codable, Hashable, Sendable {
    /// The month pillar changes at each exact *Jie* solar-term instant.
    case jieExact
}
