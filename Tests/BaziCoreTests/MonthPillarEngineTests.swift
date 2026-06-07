import BaziCore
import BaziCoreAstronomy
import Testing

@Suite("Month pillar engine")
struct MonthPillarEngineTests {
    /// Year+month pillars for 2025, one representative date inside each 节 month.
    private let referenceMonths2025: [(month: Int, day: Int, year: String, monthPillar: String)] = [
        (2, 15, "乙巳", "戊寅"), // 寅月
        (3, 15, "乙巳", "己卯"), // 卯月
        (4, 15, "乙巳", "庚辰"), // 辰月
        (5, 15, "乙巳", "辛巳"), // 巳月
        (6, 15, "乙巳", "壬午"), // 午月
        (7, 15, "乙巳", "癸未"), // 未月
        (8, 15, "乙巳", "甲申"), // 申月
        (9, 15, "乙巳", "乙酉"), // 酉月
        (10, 15, "乙巳", "丙戌"), // 戌月
        (11, 15, "乙巳", "丁亥"), // 亥月
        (12, 15, "乙巳", "戊子"), // 子月
        (1, 15, "甲辰", "丁丑") // 丑月 (before 立春, previous sexagenary year)
    ]

    @Test func allTwelveJieMonths2025() throws {
        for ref in referenceMonths2025 {
            let moment = try EngineTestSupport.moment(2025, ref.month, ref.day, 12)
            let (year, month) = try EngineTestSupport.yearAndMonth(moment)
            #expect(year.chinese == ref.year, "year for 2025-\(ref.month)")
            #expect(month.chinese == ref.monthPillar, "month for 2025-\(ref.month)")
        }
    }

    @Test func liChunSwitchesMonthFromChouToYin() throws {
        let before = try EngineTestSupport.moment(2025, 2, 3, 22, 9)
        let after = try EngineTestSupport.moment(2025, 2, 3, 22, 11)
        #expect(try EngineTestSupport.yearAndMonth(before).month.chinese == "丁丑")
        #expect(try EngineTestSupport.yearAndMonth(after).month.chinese == "戊寅")
    }

    @Test func jingZheSwitchesMonthFromYinToMao() throws {
        // 惊蛰 2025 is 2025-03-05 ~16:07 Beijing.
        let before = try EngineTestSupport.moment(2025, 3, 5, 14, 0)
        let after = try EngineTestSupport.moment(2025, 3, 5, 18, 0)
        #expect(try EngineTestSupport.yearAndMonth(before).month.branch == .yin)
        #expect(try EngineTestSupport.yearAndMonth(after).month.branch == .mao)
    }

    @Test func decemberZiMonthUsesCorrectYearStem() throws {
        // Regression guard: Dec 子月 must use the current sexagenary year stem
        // (乙巳 -> 戊子), not the previous year as a naive calendar rule would.
        let moment = try EngineTestSupport.moment(2025, 12, 20, 12)
        #expect(try EngineTestSupport.yearAndMonth(moment).month.chinese == "戊子")
    }

    @Test func recordsMonthBoundaryTrace() throws {
        let moment = try EngineTestSupport.moment(2025, 6, 15, 12)
        let year = try EngineTestSupport.yearResult(moment)
        let result = try MonthPillarEngine.compute(
            instant: moment.instant, gregorianYear: moment.year,
            yearStem: year.pillar.stem, provider: EngineTestSupport.provider
        )
        #expect(result.monthNumber == 5) // 午月
        #expect(result.details.contains { $0.key == .monthBoundaryInstant })
    }

    @Test func missingCurrentJieTermThrowsInsteadOfUsingOlderBoundary() throws {
        let moment = try EngineTestSupport.moment(2025, 3, 15, 12)
        let year = try EngineTestSupport.yearResult(moment)
        let provider = MissingJieProvider(missingTerm: .jingZhe, missingYear: 2025)

        #expect(throws: BaziError.solarTermUnavailable(term: .jingZhe, year: 2025)) {
            try MonthPillarEngine.compute(
                instant: moment.instant, gregorianYear: moment.year,
                yearStem: year.pillar.stem, provider: provider
            )
        }
    }

    @Test func optimizedJieLookupStillRequiresCurrentBoundary() throws {
        let moment = try EngineTestSupport.moment(2025, 3, 15, 12)
        let year = try EngineTestSupport.yearResult(moment)
        let provider = MissingJieProvider(missingTerm: .jingZhe, missingYear: 2025)

        #expect(throws: BaziError.solarTermUnavailable(term: .jingZhe, year: 2025)) {
            try MonthPillarEngine.compute(
                instant: moment.instant, gregorianYear: moment.year,
                yearStem: year.pillar.stem, gregorianMonth: moment.month, provider: provider
            )
        }
    }
}

private struct MissingJieProvider: SolarTermInstantProvider {
    let missingTerm: SolarTermKind
    let missingYear: Int

    private let base = AstronomicalSolarTermProvider()

    func solarTermInstant(_ term: SolarTermKind, gregorianYear year: Int) -> SolarTermInstant? {
        guard term != missingTerm || year != missingYear else { return nil }
        return base.solarTermInstant(term, gregorianYear: year)
    }

    var providerKind: BaziProviderKind { .algorithmic }
}
