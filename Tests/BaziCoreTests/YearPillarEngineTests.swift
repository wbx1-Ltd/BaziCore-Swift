import BaziCore
import Testing

@Suite("Year pillar engine")
struct YearPillarEngineTests {
    @Test func beforeLiChunUsesPreviousYear() throws {
        // 立春 2025 is 2025-02-03 22:10 Beijing; one minute before stays in 甲辰.
        let moment = try EngineTestSupport.moment(2025, 2, 3, 22, 9)
        let result = try EngineTestSupport.yearResult(moment)
        #expect(result.pillar.chinese == "甲辰")
        #expect(result.effectiveYear == 2024)
        #expect(result.notes.contains(.birthBeforeLiChun))
    }

    @Test func atOrAfterLiChunUsesCurrentYear() throws {
        let moment = try EngineTestSupport.moment(2025, 2, 3, 22, 11)
        let result = try EngineTestSupport.yearResult(moment)
        #expect(result.pillar.chinese == "乙巳")
        #expect(result.effectiveYear == 2025)
        #expect(result.notes.contains(.birthAtOrAfterLiChun))
    }

    @Test func decemberStaysInCurrentSexagenaryYear() throws {
        let moment = try EngineTestSupport.moment(2025, 12, 15, 12)
        #expect(try EngineTestSupport.yearResult(moment).pillar.chinese == "乙巳")
    }

    @Test func januaryBeforeLiChunIsPreviousYear() throws {
        let moment = try EngineTestSupport.moment(2025, 1, 15, 12)
        #expect(try EngineTestSupport.yearResult(moment).pillar.chinese == "甲辰")
    }

    @Test func tracesLiChunInstant() throws {
        let moment = try EngineTestSupport.moment(2025, 6, 1, 12)
        let result = try EngineTestSupport.yearResult(moment)
        #expect(result.notes.contains(.yearBoundaryLiChunExact))
        #expect(result.details.contains { $0.key == .liChunInstant && $0.date != nil })
    }

    @Test func lunarNewYearBoundaryRequiresLunarProvider() throws {
        let moment = try EngineTestSupport.moment(2025, 6, 1, 12)
        #expect(throws: BaziError.self) {
            try YearPillarEngine.compute(
                instant: moment.instant, gregorianYear: moment.year,
                rule: .lunarNewYear, provider: EngineTestSupport.provider
            )
        }
    }
}
