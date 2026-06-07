import BaziCore
import BaziCoreLunarCoreAdapter
import Foundation
import LunarCore
import Testing

@Suite("LunarCore bridge")
struct LunarCoreBridgeTests {
    @Test func stemAndBranchRoundTrip() {
        for tianGan in TianGan.allCases {
            let stem = LunarCoreGanZhiBridge.heavenlyStem(from: tianGan)
            #expect(stem.rawValue == tianGan.rawValue)
            #expect(LunarCoreGanZhiBridge.tianGan(from: stem) == tianGan)
            #expect(stem.chinese == tianGan.chinese)
        }
        for diZhi in DiZhi.allCases {
            let branch = LunarCoreGanZhiBridge.earthlyBranch(from: diZhi)
            #expect(branch.rawValue == diZhi.rawValue)
            #expect(LunarCoreGanZhiBridge.diZhi(from: branch) == diZhi)
        }
    }

    @Test func ganZhiCycleRoundTrip() {
        for index in 0..<60 {
            let ganZhi = GanZhi(index: index)
            let cycle = LunarCoreGanZhiBridge.sexagenaryCycle(from: ganZhi)
            #expect(cycle.index == index)
            #expect(cycle.chinese == ganZhi.chinese)
            #expect(LunarCoreGanZhiBridge.ganZhi(from: cycle).index == index)
        }
    }

    @Test func solarTermRoundTrip() {
        for solarTerm in SolarTerm.allCases {
            let kind = LunarCoreGanZhiBridge.solarTermKind(from: solarTerm)
            #expect(kind.rawValue == solarTerm.rawValue)
            #expect(kind.chineseName == solarTerm.chineseName)
            #expect(LunarCoreGanZhiBridge.solarTerm(from: kind) == solarTerm)
        }
    }

    @Test func dayPillarMatchesBaziCoreEngine() {
        let provider = LunarCoreBaziProvider()
        let cases: [(Int, Int, Int)] = [
            (2000, 1, 7), (2000, 1, 8), (2024, 6, 15), (1995, 6, 15), (2023, 12, 20)
        ]
        for (year, month, day) in cases {
            let lunarCore = provider.dayCycle(gregorianYear: year, month: month, day: day)
            let baziCore = DayPillarEngine.compute(
                year: year, month: month, day: day, hour: 12,
                dayBoundary: .civilMidnight, ziHourPolicy: .lateZiNextDay
            ).pillar.cycle
            #expect(lunarCore == baziCore)
        }
    }

    @Test func solarTermProviderReportsLunarCoreDate() throws {
        let provider = LunarCoreSolarTermProvider()
        let instant = provider.solarTermInstant(.liChun, gregorianYear: 2025)
        #expect(instant != nil)
        #expect(provider.providerKind == .lunarCalendar)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Shanghai"))
        if let date = instant?.date,
           let expected = LunarCalendar.shared.solarTermDate(.liChun, in: 2025)
        {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == expected.year)
            #expect(components.month == expected.month)
            #expect(components.day == expected.day)
        }
    }
}
