import BaziCore
import Testing

@Suite("Hour pillar engine")
struct HourPillarEngineTests {
    @Test func fiveRatHourStemGroups() {
        // 子时 (hour 0) stem by day stem group.
        let expected: [(HeavenlyStem, String)] = [
            (.jia, "甲子"), (.ji, "甲子"), // 甲己 -> 甲子
            (.yi, "丙子"), (.geng, "丙子"), // 乙庚 -> 丙子
            (.bing, "戊子"), (.xin, "戊子"), // 丙辛 -> 戊子
            (.ding, "庚子"), (.ren, "庚子"), // 丁壬 -> 庚子
            (.wu, "壬子"), (.gui, "壬子") // 戊癸 -> 壬子
        ]
        for (dayStem, hour) in expected {
            #expect(HourPillarEngine.compute(effectiveHour: 0, dayStem: dayStem).pillar.chinese == hour)
        }
    }

    @Test func branchWindows() {
        let jia = HeavenlyStem.jia
        #expect(HourPillarEngine.compute(effectiveHour: 23, dayStem: jia).pillar.branch == .zi)
        #expect(HourPillarEngine.compute(effectiveHour: 0, dayStem: jia).pillar.branch == .zi)
        #expect(HourPillarEngine.compute(effectiveHour: 1, dayStem: jia).pillar.branch == .chou)
        #expect(HourPillarEngine.compute(effectiveHour: 2, dayStem: jia).pillar.branch == .chou)
        #expect(HourPillarEngine.compute(effectiveHour: 12, dayStem: jia).pillar.branch == .wu)
        #expect(HourPillarEngine.compute(effectiveHour: 22, dayStem: jia).pillar.branch == .hai)
    }

    @Test func anchorNoonHour() throws {
        // 2000-01-07 is 甲子 day; noon is 午时 -> 庚午.
        let moment = try EngineTestSupport.moment(2000, 1, 7, 12)
        let (_, hour) = EngineTestSupport.dayAndHour(moment)
        #expect(hour.chinese == "庚午")
    }

    @Test func lateZiNextDayHourUsesNextDayStem() throws {
        // 2024-06-15 庚戌; under lateZiNextDay the day rolls to 辛亥, so 子时 is 戊子.
        let moment = try EngineTestSupport.moment(2024, 6, 15, 23, 30)
        let (day, hour) = EngineTestSupport.dayAndHour(moment, ziHourPolicy: .lateZiNextDay)
        #expect(day.chinese == "辛亥")
        #expect(hour.chinese == "戊子")
    }

    @Test func lateZiSameDayHourUsesCurrentDayStem() throws {
        let moment = try EngineTestSupport.moment(2024, 6, 15, 23, 30)
        let (day, hour) = EngineTestSupport.dayAndHour(moment, ziHourPolicy: .lateZiSameDay)
        #expect(day.chinese == "庚戌")
        #expect(hour.chinese == "丙子")
    }

    @Test func earlyZiHourMatchesReference() throws {
        // 2024-06-15 00:30 stays 庚戌; 庚 day 子时 -> 丙子.
        let moment = try EngineTestSupport.moment(2024, 6, 15, 0, 30)
        let (day, hour) = EngineTestSupport.dayAndHour(moment)
        #expect(day.chinese == "庚戌")
        #expect(hour.chinese == "丙子")
    }
}
