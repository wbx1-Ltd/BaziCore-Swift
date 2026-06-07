import BaziCore
import BaziCoreAstronomy
import Foundation
import Testing

/// Checks the astronomical solar-term instants against known reference times to the second.
@Suite("Solar-term reference parity")
struct SolarTermParityTests {
    private let provider = AstronomicalSolarTermProvider()

    private func utc(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: y, month: mo, day: d, hour: h, minute: mi))!
    }

    @Test func cardinalTerms2025() throws {
        let references: [(SolarTermKind, Date)] = [
            (.chunFen, utc(2025, 3, 20, 9, 1)),
            (.xiaZhi, utc(2025, 6, 21, 2, 42)),
            (.qiuFen, utc(2025, 9, 22, 18, 19)),
            (.dongZhi, utc(2025, 12, 21, 15, 3))
        ]
        for (term, reference) in references {
            let instant = try #require(provider.solarTermInstant(term, gregorianYear: 2025))
            #expect(abs(instant.date.timeIntervalSince(reference)) < 120, "\(term.chineseName)")
        }
    }

    @Test func liChun2025AtChinaStandardTime() throws {
        // 立春 2025 is 2025-02-03 22:10 at UTC+8.
        let instant = try #require(provider.solarTermInstant(.liChun, gregorianYear: 2025))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Shanghai"))
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: instant.date)
        #expect(components.month == 2)
        #expect(components.day == 3)
        #expect(components.hour == 22)
        #expect((9...11).contains(components.minute ?? 0))
    }
}
