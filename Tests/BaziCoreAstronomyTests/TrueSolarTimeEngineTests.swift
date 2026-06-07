import BaziCore
import BaziCoreAstronomy
import Foundation
import Testing

@Suite("True solar time engine")
struct TrueSolarTimeEngineTests {
    private let engine = TrueSolarTimeEngine()

    @Test func oneDegreeEastEqualsFourMinutes() throws {
        // Asia/Shanghai's standard meridian is 120°E; China has no DST in 2025.
        let moment = try CivilMoment(
            year: 2025, month: 6, day: 1, hour: 12, minute: 0,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let location = CalculationLocation(longitude: 121.0)
        let correction = try #require(
            engine.solarTimeCorrection(for: moment, location: location, policy: .localMeanSolarTime)
        )
        // 1° east of the 120°E meridian -> +4 minutes (240 s).
        #expect(abs(correction.longitudeCorrectionSeconds - 240) < 0.001)
        #expect(correction.daylightSavingSeconds == 0)
        #expect(correction.hour == 12)
        #expect(correction.minute == 4)
    }

    @Test func onMeridianHasNoLongitudeCorrection() throws {
        let moment = try CivilMoment(
            year: 2025, month: 6, day: 1, hour: 9, minute: 30,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let location = CalculationLocation(longitude: 120.0)
        let correction = try #require(
            engine.solarTimeCorrection(for: moment, location: location, policy: .localMeanSolarTime)
        )
        #expect(abs(correction.longitudeCorrectionSeconds) < 0.001)
        #expect(correction.hour == 9)
        #expect(correction.minute == 30)
    }

    @Test func daylightSavingIsRemovedBeforeCorrection() throws {
        // America/New_York on 1 July 2025 is EDT (UTC-4); standard meridian -75°.
        let moment = try CivilMoment(
            year: 2025, month: 7, day: 1, hour: 12, minute: 0,
            timeZoneIdentifier: "America/New_York"
        )
        let location = CalculationLocation(longitude: -75.0)
        let correction = try #require(
            engine.solarTimeCorrection(for: moment, location: location, policy: .localMeanSolarTime)
        )
        // On the standard meridian, only the 1-hour DST offset is removed.
        #expect(correction.daylightSavingSeconds == 3600)
        #expect(abs(correction.longitudeCorrectionSeconds) < 0.001)
        #expect(correction.totalCorrectionSeconds == -3600)
        #expect(correction.hour == 11)
        #expect(correction.minute == 0)
    }

    @Test func trueSolarTimeAddsEquationOfTime() throws {
        let moment = try CivilMoment(
            year: 2025, month: 11, day: 3, hour: 12, minute: 0,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let location = CalculationLocation(longitude: 120.0)
        let mean = try #require(
            engine.solarTimeCorrection(for: moment, location: location, policy: .localMeanSolarTime)
        )
        let trueSolar = try #require(
            engine.solarTimeCorrection(for: moment, location: location, policy: .trueSolarTime)
        )
        // Early November equation of time is ~+16.5 minutes.
        #expect(mean.equationOfTimeSeconds == 0)
        #expect((960...1010).contains(trueSolar.equationOfTimeSeconds))
        #expect(trueSolar.minute == 16)
    }

    @Test func standardClockIsIdentity() throws {
        let moment = try CivilMoment(
            year: 2025, month: 3, day: 10, hour: 8, minute: 45,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let correction = try #require(
            engine.solarTimeCorrection(
                for: moment, location: CalculationLocation(), policy: .standardClock
            )
        )
        #expect(correction.hour == 8)
        #expect(correction.minute == 45)
        #expect(correction.totalCorrectionSeconds == 0)
    }

    @Test func missingLongitudeYieldsNoCorrection() throws {
        let moment = try CivilMoment(
            year: 2025, month: 3, day: 10, hour: 8, minute: 45,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let correction = engine.solarTimeCorrection(
            for: moment, location: CalculationLocation(), policy: .trueSolarTime
        )
        #expect(correction == nil)
    }
}
