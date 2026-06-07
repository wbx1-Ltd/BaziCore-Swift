import BaziCore
import Foundation

/// The starting point of the luck cycle (起运): how long after birth the first 大运 begins, and when.
public struct ChildLimit: Codable, Hashable, Sendable {
    /// The luck-cycle direction this child limit was computed for.
    public let direction: LuckDirection
    /// The rule used to derive the duration.
    public let rule: ChildLimitRule
    public let years: Int
    public let months: Int
    public let days: Int
    public let hours: Int
    public let minutes: Int
    /// The instant the first 大运 begins (birth plus the duration).
    public let startDate: Date
    /// The Gregorian year the first 大运 begins, in the birth's time zone.
    public let startGregorianYear: Int
    /// The neighbouring 节 term the duration was measured against.
    public let boundaryTerm: SolarTermKind
    /// The instant of that 节 term.
    public let boundaryInstant: Date

    public init(
        direction: LuckDirection,
        rule: ChildLimitRule,
        years: Int, months: Int, days: Int, hours: Int, minutes: Int,
        startDate: Date,
        startGregorianYear: Int,
        boundaryTerm: SolarTermKind,
        boundaryInstant: Date
    ) {
        self.direction = direction
        self.rule = rule
        self.years = years
        self.months = months
        self.days = days
        self.hours = hours
        self.minutes = minutes
        self.startDate = startDate
        self.startGregorianYear = startGregorianYear
        self.boundaryTerm = boundaryTerm
        self.boundaryInstant = boundaryInstant
    }
}
