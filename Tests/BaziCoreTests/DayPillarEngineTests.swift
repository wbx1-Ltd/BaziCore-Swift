import BaziCore
import Testing

@Suite("Day pillar engine")
struct DayPillarEngineTests {
    @Test func referenceDayIsJiaZi() throws {
        let moment = try EngineTestSupport.moment(2000, 1, 7, 12)
        #expect(EngineTestSupport.dayPillar(moment).chinese == "甲子")
    }

    @Test func consecutiveDaysIncrementByOne() throws {
        #expect(try EngineTestSupport.dayPillar(EngineTestSupport.moment(2000, 1, 8, 12)).chinese == "乙丑")
        #expect(try EngineTestSupport.dayPillar(EngineTestSupport.moment(2024, 6, 15, 12)).chinese == "庚戌")
        #expect(try EngineTestSupport.dayPillar(EngineTestSupport.moment(2024, 6, 16, 12)).chinese == "辛亥")
    }

    @Test func dayIndexAdvancesOneStepPerDay() throws {
        var previous: Int?
        for day in 7...16 {
            let pillar = try EngineTestSupport.dayPillar(EngineTestSupport.moment(2000, 1, day, 12))
            if let previous {
                #expect(pillar.ganZhiIndex == (previous + 1) % 60)
            }
            previous = pillar.ganZhiIndex
        }
    }

    @Test func earlyZiHourDoesNotRollDay() throws {
        // 00:30 is early 子时: it stays on the calendar day.
        let moment = try EngineTestSupport.moment(2024, 6, 15, 0, 30)
        #expect(EngineTestSupport.dayPillar(moment).chinese == "庚戌")
    }

    @Test func lateZiNextDayRollsDayForward() throws {
        // 23:30 with the professional default rolls to the next day's pillar.
        let moment = try EngineTestSupport.moment(2024, 6, 15, 23, 30)
        #expect(EngineTestSupport.dayPillar(moment, ziHourPolicy: .lateZiNextDay).chinese == "辛亥")
    }

    @Test func lateZiSameDayKeepsDay() throws {
        let moment = try EngineTestSupport.moment(2024, 6, 15, 23, 30)
        #expect(EngineTestSupport.dayPillar(moment, ziHourPolicy: .lateZiSameDay).chinese == "庚戌")
    }

    @Test func ziHourStartBoundaryAlwaysRollsAt23() throws {
        let moment = try EngineTestSupport.moment(2024, 6, 15, 23, 30)
        let pillar = EngineTestSupport.dayPillar(
            moment, dayBoundary: .ziHourStart, ziHourPolicy: .lateZiSameDay
        )
        #expect(pillar.chinese == "辛亥")
    }

    @Test func recordsBoundaryNotes() throws {
        let moment = try EngineTestSupport.moment(2024, 6, 15, 23, 30)
        let result = DayPillarEngine.compute(
            year: moment.year, month: moment.month, day: moment.day, hour: moment.hour,
            dayBoundary: .civilMidnight, ziHourPolicy: .lateZiNextDay
        )
        #expect(result.notes.contains(.lateZiHourRolledToNextDay))
        #expect(result.effectiveDayDescription == "2024-06-16")
    }
}
