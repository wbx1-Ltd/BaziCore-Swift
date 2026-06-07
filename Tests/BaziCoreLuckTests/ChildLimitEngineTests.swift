import BaziCore
import BaziCoreAstronomy
import BaziCoreLuck
import Foundation
import Testing

@Suite("Child limit engine")
struct ChildLimitEngineTests {
    private func birth(
        _ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int, tz: String = "UTC"
    ) throws -> CivilMoment {
        try CivilMoment(year: y, month: mo, day: d, hour: h, minute: mi, timeZoneIdentifier: tz)
    }

    /// Returns a stub whose next forward 节 sits exactly `seconds` after birth.
    private func stub(forwardSeconds seconds: Double, from birth: CivilMoment) -> StubSolarTermProvider {
        let target = birth.instant.addingTimeInterval(seconds)
        return StubSolarTermProvider { term, year in
            term == .xiaoShu && year == birth.year ? target : nil
        }
    }

    @Test func threeRealDaysIsOneYear() throws {
        let moment = try birth(2000, 3, 15, 12, 0)
        let limit = try ChildLimitEngine.compute(
            birth: moment, direction: .forward, rule: .threeDaysPerYear,
            provider: stub(forwardSeconds: 3 * 86400, from: moment)
        )
        #expect(limit.years == 1)
        #expect(limit.months == 0)
        #expect(limit.days == 0)
    }

    @Test func conversionRatios() throws {
        let moment = try birth(2000, 3, 15, 12, 0)
        // 1 real day -> 4 months; 1 real hour -> 5 days; combined with 3 days -> 1 year.
        let limit = try ChildLimitEngine.compute(
            birth: moment, direction: .forward, rule: .threeDaysPerYear,
            provider: stub(forwardSeconds: 3 * 86400 + 86400 + 3600, from: moment)
        )
        #expect(limit.years == 1)
        #expect(limit.months == 4)
        #expect(limit.days == 5)
    }

    @Test func directionMatrixFollowsYearStem() {
        // 乙 (Yin) year stem.
        #expect(LuckDirection.resolve(yearStem: .yi, sex: .male) == .backward)
        #expect(LuckDirection.resolve(yearStem: .yi, sex: .female) == .forward)
        // 庚 (Yang) year stem.
        #expect(LuckDirection.resolve(yearStem: .geng, sex: .male) == .forward)
        #expect(LuckDirection.resolve(yearStem: .geng, sex: .female) == .backward)
    }

    @Test func childLimitYearsAndMonths() throws {
        // 乙亥 year (Yin). 1995 is outside China's 1986–1991 summer time, so the
        // forward/backward distance to the neighbouring 节 is unambiguous.
        let provider = AstronomicalSolarTermProvider()
        let moment = try birth(1995, 6, 15, 8, 30, tz: "Asia/Shanghai")

        let backward = try ChildLimitEngine.compute(
            birth: moment, direction: .backward, rule: .threeDaysPerYear, provider: provider
        )
        #expect(backward.years == 2)
        #expect(backward.months == 11)
        #expect(backward.boundaryTerm == .mangZhong)
        #expect(backward.startGregorianYear == 1998)

        let forward = try ChildLimitEngine.compute(
            birth: moment, direction: .forward, rule: .threeDaysPerYear, provider: provider
        )
        #expect(forward.years == 7)
        #expect(forward.months == 6)
        #expect(forward.boundaryTerm == .xiaoShu)
        #expect(forward.startGregorianYear == 2002)
    }

    @Test func forwardSkipsExactBoundaryWhileBackwardUsesIt() throws {
        let moment = try birth(2025, 7, 7, 12, 0)
        let next = moment.instant.addingTimeInterval(10 * 86400)
        let provider = StubSolarTermProvider { term, year in
            if term == .xiaoShu, year == moment.year { return moment.instant }
            if term == .liQiu, year == moment.year { return next }
            return nil
        }

        let forward = try ChildLimitEngine.compute(
            birth: moment, direction: .forward, rule: .threeDaysPerYear, provider: provider
        )
        let backward = try ChildLimitEngine.compute(
            birth: moment, direction: .backward, rule: .threeDaysPerYear, provider: provider
        )

        #expect(forward.boundaryTerm == .liQiu)
        #expect(backward.boundaryTerm == .xiaoShu)
        #expect(backward.years == 0)
        #expect(backward.months == 0)
        #expect(backward.days == 0)
    }
}
