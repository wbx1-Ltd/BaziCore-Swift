import BaziCore
import Foundation

/// A controllable solar-term provider for exercising luck-cycle math against
/// exact, synthetic boundaries.
struct StubSolarTermProvider: SolarTermInstantProvider {
    let resolver: @Sendable (SolarTermKind, Int) -> Date?

    func solarTermInstant(_ term: SolarTermKind, gregorianYear year: Int) -> SolarTermInstant? {
        resolver(term, year).map { date in
            SolarTermInstant(
                term: term, gregorianYear: year, date: date,
                julianDayUT: date.timeIntervalSince1970 / 86400.0 + 2440587.5
            )
        }
    }

    var providerKind: BaziProviderKind { .algorithmic }
}
