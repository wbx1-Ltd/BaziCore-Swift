import Foundation

/// The exact instant at which the Sun reaches a solar term's defining ecliptic longitude.
public struct SolarTermInstant: Codable, Hashable, Sendable {
    /// The solar term this instant marks.
    public let term: SolarTermKind
    /// The Gregorian calendar year in which the term occurs.
    public let gregorianYear: Int
    /// The absolute instant of the term boundary (UTC).
    public let date: Date
    /// Julian Day in Universal Time for the same instant; used for cross-checks and ordering.
    public let julianDayUT: Double

    public init(term: SolarTermKind, gregorianYear: Int, date: Date, julianDayUT: Double) {
        self.term = term
        self.gregorianYear = gregorianYear
        self.date = date
        self.julianDayUT = julianDayUT
    }
}
