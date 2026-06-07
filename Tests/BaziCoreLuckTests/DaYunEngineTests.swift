import BaziCore
import BaziCoreAstronomy
import BaziCoreLuck
import Testing

@Suite("DaYun engine")
struct DaYunEngineTests {
    private let calculator = BaziCalculator(solarTermProvider: AstronomicalSolarTermProvider())
    private let provider = AstronomicalSolarTermProvider()

    private func setup(sex: SexForLuckCycle) throws -> (chart: BaziChart, direction: LuckDirection, childLimit: ChildLimit) {
        let moment = try CivilMoment(year: 1995, month: 6, day: 15, hour: 8, minute: 30, timeZoneIdentifier: "Asia/Shanghai")
        let chart = try calculator.chart(for: BirthInput(moment: moment, sexForLuckCycle: sex))
        let direction = LuckDirection.resolve(yearStem: chart.fourPillars.year.stem, sex: sex)
        let childLimit = try ChildLimitEngine.compute(
            birth: moment, direction: direction, rule: .threeDaysPerYear, provider: provider
        )
        return (chart, direction, childLimit)
    }

    @Test func backwardMaleSequence() throws {
        let (chart, direction, childLimit) = try setup(sex: .male)
        #expect(direction == .backward)
        let dayun = DaYunEngine.compute(
            monthPillar: chart.fourPillars.month.cycle, birthGregorianYear: 1995,
            childLimit: childLimit, direction: direction, count: 4
        )
        #expect(dayun.map(\.pillar.chinese) == ["辛巳", "庚辰", "己卯", "戊寅"])
        #expect(dayun[0].startAge == 4)
        #expect(dayun[0].startGregorianYear == 1998)
        #expect(dayun[1].startGregorianYear == 2008)
        #expect(dayun[0].endGregorianYear == 2007)
    }

    @Test func forwardFemaleSequence() throws {
        let (chart, direction, childLimit) = try setup(sex: .female)
        #expect(direction == .forward)
        let dayun = DaYunEngine.compute(
            monthPillar: chart.fourPillars.month.cycle, birthGregorianYear: 1995,
            childLimit: childLimit, direction: direction, count: 4
        )
        #expect(dayun.map(\.pillar.chinese) == ["癸未", "甲申", "乙酉", "丙戌"])
        #expect(dayun[0].startAge == 8)
        #expect(dayun[0].startGregorianYear == 2002)
    }

    @Test func eachPeriodSpansTenYears() throws {
        let (chart, direction, childLimit) = try setup(sex: .male)
        let dayun = DaYunEngine.compute(
            monthPillar: chart.fourPillars.month.cycle, birthGregorianYear: 1995,
            childLimit: childLimit, direction: direction, count: 6
        )
        for index in 1..<dayun.count {
            #expect(dayun[index].startGregorianYear - dayun[index - 1].startGregorianYear == 10)
            #expect(dayun[index].startAge - dayun[index - 1].startAge == 10)
        }
    }
}
