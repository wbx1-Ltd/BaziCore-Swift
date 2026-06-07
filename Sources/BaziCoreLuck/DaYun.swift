import BaziCore

/// One ten-year luck period (大运).
public struct DaYun: Codable, Hashable, Sendable {
    /// Zero-based position; 0 is the first 大运 after 起运.
    public let index: Int
    /// The sexagenary pair governing this period.
    public let pillar: SexagenaryCycle
    /// The counting age (虚岁, birth = 1) at which this period begins.
    public let startAge: Int
    /// The Gregorian year this period begins.
    public let startGregorianYear: Int
    /// The Gregorian year this period ends (inclusive, nine years later).
    public let endGregorianYear: Int

    public init(
        index: Int,
        pillar: SexagenaryCycle,
        startAge: Int,
        startGregorianYear: Int,
        endGregorianYear: Int
    ) {
        self.index = index
        self.pillar = pillar
        self.startAge = startAge
        self.startGregorianYear = startGregorianYear
        self.endGregorianYear = endGregorianYear
    }
}
