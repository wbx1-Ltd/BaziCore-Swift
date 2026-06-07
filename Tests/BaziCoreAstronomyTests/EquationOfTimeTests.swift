import BaziCoreAstronomy
import Foundation
import Testing

@Suite("Equation of time")
struct EquationOfTimeTests {
    private func utcNoon(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    @Test func februaryMinimum() {
        // Around 11 February the sundial lags the clock by ~14 minutes.
        let value = EquationOfTime.minutes(at: utcNoon(2025, 2, 11))
        #expect((-14.6...(-13.8)).contains(value))
    }

    @Test func novemberMaximum() {
        // Around 3 November the sundial leads the clock by ~16.4 minutes.
        let value = EquationOfTime.minutes(at: utcNoon(2025, 11, 3))
        #expect((16.0...16.9).contains(value))
    }

    @Test func aprilNearZero() {
        let value = EquationOfTime.minutes(at: utcNoon(2025, 4, 15))
        #expect(abs(value) < 0.5)
    }

    @Test func julyDip() {
        let value = EquationOfTime.minutes(at: utcNoon(2025, 7, 26))
        #expect((-7.0...(-6.0)).contains(value))
    }

    @Test func staysWithinPhysicalBounds() throws {
        // The equation of time never exceeds roughly +/-16.5 minutes.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "UTC"))
        for dayOfYear in stride(from: 0, to: 365, by: 1) {
            let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
                .addingTimeInterval(Double(dayOfYear) * 86400)
            let value = EquationOfTime.minutes(at: date)
            #expect(abs(value) < 17.0)
        }
    }
}
