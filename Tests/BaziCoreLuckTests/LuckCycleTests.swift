import BaziCore
import BaziCoreAstronomy
import BaziCoreLuck
import Foundation
import Testing

@Suite("Luck cycle convenience")
struct LuckCycleTests {
    private let calculator = BaziCalculator(solarTermProvider: AstronomicalSolarTermProvider())
    private let provider = AstronomicalSolarTermProvider()

    private func chart(sex: SexForLuckCycle?) throws -> BaziChart {
        let moment = try CivilMoment(
            year: 1995, month: 6, day: 15, hour: 8, minute: 30, timeZoneIdentifier: "Asia/Shanghai"
        )
        return try calculator.chart(for: BirthInput(moment: moment, sexForLuckCycle: sex))
    }

    @Test func computesFullCycleInOneCall() throws {
        let luck = try LuckCycle.compute(
            chart: chart(sex: .female), provider: provider, daYunCount: 4, xiaoYunCount: 10
        )
        #expect(luck.direction == .forward)
        #expect(luck.childLimit.years == 7)
        #expect(luck.childLimit.months == 6)
        #expect(luck.daYun.map(\.pillar.chinese) == ["癸未", "甲申", "乙酉", "丙戌"])
        #expect(luck.daYun[0].startGregorianYear == 2002)
        #expect(luck.xiaoYun.count == 10)
        // 虚岁 8 (2002) is the first year of the first 大运.
        #expect(luck.xiaoYun.first { $0.gregorianYear == 2002 }?.pillar.chinese == "壬子")
    }

    @Test func requiresSexMarker() throws {
        let chartWithoutSex = try chart(sex: nil)
        #expect(throws: BaziError.missingSexForLuckCycle) {
            try LuckCycle.compute(chart: chartWithoutSex, provider: provider)
        }
    }

    @Test func zeroXiaoYunCountReturnsEmptySeries() throws {
        let luck = try LuckCycle.compute(
            chart: chart(sex: .female), provider: provider, daYunCount: 1, xiaoYunCount: 0
        )
        #expect(luck.daYun.count == 1)
        #expect(luck.xiaoYun.isEmpty)
    }

    @Test func roundTripsThroughCodable() throws {
        let luck = try LuckCycle.compute(chart: chart(sex: .male), provider: provider, daYunCount: 3, xiaoYunCount: 3)
        let data = try JSONEncoder().encode(luck)
        let decoded = try JSONDecoder().decode(LuckCycle.self, from: data)
        #expect(decoded == luck)
    }
}
