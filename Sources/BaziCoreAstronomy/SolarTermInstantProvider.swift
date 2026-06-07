import BaziCore
import Foundation

/// High-precision ``SolarTermInstantProvider``: each term as the exact instant the Sun's apparent longitude reaches its angle.
public struct AstronomicalSolarTermProvider: SolarTermInstantProvider {
    private let cache: SolarTermCache

    public init() {
        cache = SolarTermCache()
    }

    public func solarTermInstant(_ term: SolarTermKind, gregorianYear year: Int) -> SolarTermInstant? {
        guard SolarLongitude.supportedYearRange.contains(year) else { return nil }

        let key = SolarTermCache.Key(term: term, year: year)
        if let cached = cache.value(for: key) {
            return cached.instant
        }

        guard let jd = SolarLongitude.crossingJulianDay(target: term.solarLongitude, gregorianYear: year) else {
            cache.insert(.missing, for: key)
            return nil
        }
        let instant = SolarTermInstant(
            term: term,
            gregorianYear: year,
            date: SolarLongitude.date(julianDay: jd),
            julianDayUT: jd
        )
        cache.insert(.resolved(instant), for: key)
        return instant
    }

    public func solarTermInstants(inGregorianYear year: Int) -> [SolarTermInstant] {
        var instants: [SolarTermInstant] = []
        instants.reserveCapacity(SolarTermKind.allCases.count)
        for term in SolarTermKind.allCases {
            if let instant = solarTermInstant(term, gregorianYear: year) {
                instants.append(instant)
            }
        }
        return instants
    }
}

private final class SolarTermCache: @unchecked Sendable {
    struct Key: Hashable {
        let term: SolarTermKind
        let year: Int
    }

    enum Entry {
        case resolved(SolarTermInstant)
        case missing

        var instant: SolarTermInstant? {
            switch self {
            case .resolved(let instant): instant
            case .missing: nil
            }
        }
    }

    private let lock = NSLock()
    private var entries: [Key: Entry] = [:]

    func value(for key: Key) -> Entry? {
        lock.lock()
        defer { lock.unlock() }
        return entries[key]
    }

    func insert(_ entry: Entry, for key: Key) {
        lock.lock()
        defer { lock.unlock() }
        entries[key] = entry
    }
}
