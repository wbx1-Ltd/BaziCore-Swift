import BaziCore
import Foundation

/// Derives the child limit (起运) — the age at which the luck cycle begins.
public enum ChildLimitEngine {
    // Real seconds per unit of age, from 3 real days = 1 year.
    private static let secondsPerYear = 259200.0
    private static let secondsPerMonth = 21600.0
    private static let secondsPerDay = 720.0
    private static let secondsPerHour = 30.0
    private static let secondsPerMinute = 0.5

    public static func compute(
        birth: CivilMoment,
        direction: LuckDirection,
        rule: ChildLimitRule,
        provider: any SolarTermInstantProvider
    ) throws(BaziError) -> ChildLimit {
        guard let boundary = boundaryTerm(birth: birth, direction: direction, provider: provider) else {
            throw .solarTermUnavailable(term: .liChun, year: birth.year)
        }

        let gapSeconds = direction == .forward
            ? boundary.date.timeIntervalSince(birth.instant)
            : birth.instant.timeIntervalSince(boundary.date)

        var remainder = max(0, gapSeconds)
        let years = Int(remainder / secondsPerYear)
        remainder -= Double(years) * secondsPerYear
        let months = Int(remainder / secondsPerMonth)
        remainder -= Double(months) * secondsPerMonth
        let days = Int(remainder / secondsPerDay)
        remainder -= Double(days) * secondsPerDay
        let hours = Int(remainder / secondsPerHour)
        remainder -= Double(hours) * secondsPerHour
        let minutes = Int(remainder / secondsPerMinute)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = birth.timeZone
        let startDate = calendar.date(
            byAdding: DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes),
            to: birth.instant
        ) ?? birth.instant
        let startGregorianYear = calendar.component(.year, from: startDate)

        return ChildLimit(
            direction: direction,
            rule: rule,
            years: years, months: months, days: days, hours: hours, minutes: minutes,
            startDate: startDate,
            startGregorianYear: startGregorianYear,
            boundaryTerm: boundary.term,
            boundaryInstant: boundary.date
        )
    }

    /// The next (forward) or previous (backward) 节 term relative to birth.
    private static func boundaryTerm(
        birth: CivilMoment,
        direction: LuckDirection,
        provider: any SolarTermInstantProvider
    ) -> SolarTermInstant? {
        let birthInstant = birth.instant
        var boundary: SolarTermInstant?
        for year in (birth.year - 1)...(birth.year + 1) {
            for term in SolarTermKind.allCases where term.isMonthBoundaryTerm {
                guard let instant = provider.solarTermInstant(term, gregorianYear: year) else {
                    continue
                }
                switch direction {
                case .forward:
                    if instant.date > birthInstant, boundary == nil || instant.date < boundary!.date {
                        boundary = instant
                    }
                case .backward:
                    if instant.date <= birthInstant, boundary == nil || instant.date > boundary!.date {
                        boundary = instant
                    }
                }
            }
        }
        return boundary
    }
}
