import BaziCore
import BaziCoreLuck
import BaziCoreTables
import Testing

@Suite("LiuNian and XiaoYun")
struct LiuNianEngineTests {
    @Test func yearPillarsAndAges() {
        let series = LiuNianEngine.series(
            birthGregorianYear: 1995, dayMaster: .ding, fromYear: 2023, count: 4
        )
        #expect(series.map(\.pillar.chinese) == ["癸卯", "甲辰", "乙巳", "丙午"])
        #expect(series.map(\.age) == [29, 30, 31, 32])
    }

    @Test func tenGodOfYearStem() {
        // Day master 丁 (Yin Fire); 2025 is 乙巳, year stem 乙 (Yin Wood) -> 偏印.
        let series = LiuNianEngine.series(
            birthGregorianYear: 1995, dayMaster: .ding, fromYear: 2025, count: 1
        )
        #expect(series[0].stemTenGod == TenGodEngine.tenGod(of: .yi, dayMaster: .ding))
        #expect(series[0].stemTenGod == .pianYin)
    }

    @Test func xiaoYunBackwardFromHourPillar() {
        // Hour pillar 甲辰 (index 40), male/backward; counting age n -> 甲辰 - n.
        let hour = SexagenaryCycle(index: 40)
        let series = XiaoYun.series(
            hourPillar: hour, birthGregorianYear: 1995, direction: .backward, count: 6
        )
        // 1998 is counting age 4 -> 庚子.
        let age4 = series.first { $0.age == 4 }
        #expect(age4?.gregorianYear == 1998)
        #expect(age4?.pillar.chinese == "庚子")
        #expect(series.first { $0.age == 5 }?.pillar.chinese == "己亥")
    }

    @Test func xiaoYunForwardFromHourPillar() {
        let hour = SexagenaryCycle(index: 40) // 甲辰
        let series = XiaoYun.series(
            hourPillar: hour, birthGregorianYear: 1995, direction: .forward, count: 10
        )
        // 2002 is counting age 8 -> 壬子.
        #expect(series.first { $0.age == 8 }?.pillar.chinese == "壬子")
    }

    @Test func xiaoYunZeroCountReturnsEmptySeries() {
        let hour = SexagenaryCycle(index: 40) // 甲辰
        let series = XiaoYun.series(
            hourPillar: hour, birthGregorianYear: 1995, direction: .forward, count: 0
        )
        #expect(series.isEmpty)
    }

    @Test func xiaoYunNegativeCountReturnsEmptySeries() {
        let hour = SexagenaryCycle(index: 40) // 甲辰
        let series = XiaoYun.series(
            hourPillar: hour, birthGregorianYear: 1995, direction: .forward, count: -1
        )
        #expect(series.isEmpty)
    }
}
