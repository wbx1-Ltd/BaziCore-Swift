import BaziCore
import Foundation
import LunarCore

/// Date-precision ``SolarTermInstantProvider``: each term at local noon (Asia/Shanghai) of its date.
public struct LunarCoreSolarTermProvider: SolarTermInstantProvider {
    private let calendar: LunarCalendar
    private static let beijing = TimeZone(identifier: "Asia/Shanghai")!

    public init(calendar: LunarCalendar = .shared) {
        self.calendar = calendar
    }

    public var providerKind: BaziProviderKind { .lunarCalendar }

    public func solarTermInstant(_ term: SolarTermKind, gregorianYear year: Int) -> SolarTermInstant? {
        let lunarTerm = LunarCoreGanZhiBridge.solarTerm(from: term)
        guard
            let date = calendar.solarTermDate(lunarTerm, in: year),
            let midnight = date.toDate(in: Self.beijing)
        else {
            return nil
        }
        // Date precision only: place the term at local noon of its date.
        let noon = midnight.addingTimeInterval(12 * 3600)
        return SolarTermInstant(
            term: term,
            gregorianYear: year,
            date: noon,
            julianDayUT: noon.timeIntervalSince1970 / 86400.0 + 2440587.5
        )
    }
}
