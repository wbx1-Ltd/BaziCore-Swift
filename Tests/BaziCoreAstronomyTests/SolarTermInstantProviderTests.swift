import BaziCore
@testable import BaziCoreAstronomy
import Foundation
import Testing

@Suite("Astronomical solar-term instant provider")
struct SolarTermInstantProviderTests {
    private let provider = AstronomicalSolarTermProvider()

    private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    @Test func vernalEquinox2025MatchesEphemeris() throws {
        let instant = try #require(provider.solarTermInstant(.chunFen, gregorianYear: 2025))
        // Published March equinox 2025: 2025-03-20 09:01 UTC.
        #expect(abs(instant.date.timeIntervalSince(utc(2025, 3, 20, 9, 1))) < 180)
    }

    @Test func liChun2025MatchesEphemeris() throws {
        let instant = try #require(provider.solarTermInstant(.liChun, gregorianYear: 2025))
        // 立春 2025: 2025-02-03 14:10 UTC (Beijing 22:10).
        #expect(abs(instant.date.timeIntervalSince(utc(2025, 2, 3, 14, 10))) < 180)
    }

    @Test func winterSolstice2024MatchesEphemeris() throws {
        let instant = try #require(provider.solarTermInstant(.dongZhi, gregorianYear: 2024))
        // Published December solstice 2024: 2024-12-21 09:21 UTC.
        #expect(abs(instant.date.timeIntervalSince(utc(2024, 12, 21, 9, 21))) < 180)
    }

    @Test func everyTermLandsOnItsTargetLongitude() throws {
        for term in SolarTermKind.allCases {
            let instant = try #require(provider.solarTermInstant(term, gregorianYear: 2025))
            let longitude = try SolarLongitude.apparentLongitude(julianDay: instant.julianDayUT)
            var delta = abs(longitude - term.solarLongitude).truncatingRemainder(dividingBy: 360)
            if delta > 180 { delta = 360 - delta }
            #expect(delta < 0.001)
        }
    }

    @Test func termsAreChronological() {
        let instants = provider.solarTermInstants(inGregorianYear: 2025)
        #expect(instants.count == 24)
        let jds = instants.map(\.julianDayUT)
        #expect(jds == jds.sorted())
    }

    @Test func repeatedConcurrentLookupsAreStable() async throws {
        let provider = AstronomicalSolarTermProvider()
        let expected = try #require(provider.solarTermInstant(.liChun, gregorianYear: 2025))

        let values = await withTaskGroup(of: Double?.self, returning: [Double?].self) { group in
            for _ in 0..<32 {
                group.addTask {
                    provider.solarTermInstant(.liChun, gregorianYear: 2025)?.julianDayUT
                }
            }

            var values: [Double?] = []
            values.reserveCapacity(32)
            for await value in group {
                values.append(value)
            }
            return values
        }

        #expect(values.allSatisfy { $0 == expected.julianDayUT })
    }

    @Test func eachInstantFallsInRequestedYear() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Shanghai"))
        for term in SolarTermKind.allCases {
            let instant = try #require(provider.solarTermInstant(term, gregorianYear: 2025))
            let year = calendar.component(.year, from: instant.date)
            #expect(year == 2025)
        }
    }
}
