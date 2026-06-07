/// Which kind of provider produced a result.
public enum BaziProviderKind: String, CaseIterable, Codable, Hashable, Sendable {
    /// Pure modular arithmetic, no dependency.
    case algorithmic
    /// High-precision astronomy.
    case astronomy
    /// Chinese lunar-calendar adapter.
    case lunarCalendar
    /// A combination of the above.
    case hybrid
}
