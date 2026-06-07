import AstroCore
import Foundation

/// Low-level solar geometry from the high-precision Sun; works in Julian Day (UT), years 1800–2100.
enum SolarLongitude {
    static let supportedYearRange: ClosedRange<Int> = 1800...2100

    /// Julian Day (UT) for a Foundation `Date`.
    static func julianDay(_ date: Date) -> Double {
        date.timeIntervalSince1970 / 86400.0 + 2440587.5
    }

    /// Foundation `Date` for a Julian Day (UT).
    static func date(julianDay jd: Double) -> Date {
        Date(timeIntervalSince1970: (jd - 2440587.5) * 86400.0)
    }

    struct OutOfRange: Error {}

    /// Builds a UTC `CivilMoment` for a Julian Day (~1-second resolution).
    static func moment(julianDay jd: Double) throws -> CivilMoment {
        let resolved = date(julianDay: jd)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: resolved
        )
        guard let year = components.year, supportedYearRange.contains(year) else {
            throw OutOfRange()
        }
        do {
            return try CivilMoment(
                year: year,
                month: components.month ?? 1,
                day: components.day ?? 1,
                hour: components.hour ?? 0,
                minute: components.minute ?? 0,
                second: components.second ?? 0,
                timeZoneIdentifier: "UTC"
            )
        } catch {
            throw OutOfRange()
        }
    }

    /// Apparent geocentric ecliptic longitude of the Sun in degrees [0, 360).
    static func apparentLongitude(julianDay jd: Double) throws -> Double {
        try AstroCalculator.sunPosition(for: moment(julianDay: jd)).longitude
    }

    /// Signed `apparentLongitude(jd) − target`, normalized to (-180, 180]; zero at the crossing.
    static func signedDelta(julianDay jd: Double, target: Double) throws -> Double {
        var delta = try (apparentLongitude(julianDay: jd) - target)
            .truncatingRemainder(dividingBy: 360)
        if delta > 180 { delta -= 360 }
        if delta <= -180 { delta += 360 }
        return delta
    }

    /// Julian Day in `year` when the Sun's apparent longitude reaches `target`°, or nil if out of range.
    static func crossingJulianDay(target: Double, gregorianYear year: Int) -> Double? {
        guard supportedYearRange.contains(year) else { return nil }

        // Seed from the mean longitude, snap to the crossing near mid-year.
        let meanRate = 0.985_647_36 // degrees per day
        let baseCrossing = 2451545.0 + (target - 280.466_46) / meanRate
        let yearMiddle = 2451545.0 + Double(year - 2000) * 365.2422 + 182.0
        let cycles = ((yearMiddle - baseCrossing) / 365.2422).rounded()
        let seed = baseCrossing + cycles * 365.2422

        guard var bracket = bracket(around: seed, target: target) else { return nil }
        for _ in 0..<60 {
            let mid = (bracket.lo + bracket.hi) / 2
            guard let fmid = try? signedDelta(julianDay: mid, target: target) else { return nil }
            if bracket.hi - bracket.lo < 1e-5 { return mid }
            if (bracket.flo < 0) == (fmid < 0) {
                bracket.lo = mid
                bracket.flo = fmid
            } else {
                bracket.hi = mid
            }
        }
        return (bracket.lo + bracket.hi) / 2
    }

    private struct Bracket {
        var lo: Double
        var hi: Double
        var flo: Double
    }

    private static func bracket(around seed: Double, target: Double) -> Bracket? {
        var halfWidth = 5.0
        for _ in 0..<5 {
            let lo = seed - halfWidth
            let hi = seed + halfWidth
            guard
                let flo = try? signedDelta(julianDay: lo, target: target),
                let fhi = try? signedDelta(julianDay: hi, target: target)
            else {
                return nil
            }
            if (flo < 0) != (fhi < 0) {
                return Bracket(lo: lo, hi: hi, flo: flo)
            }
            halfWidth *= 2
        }
        return nil
    }
}
