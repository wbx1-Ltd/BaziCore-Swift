import BaziCore
import BaziCoreTables
import Foundation
import Testing

/// Pins the full derived analysis on worked reference charts: ten gods (stem and
/// hidden), NaYin, growth stages, 胎元/命宫/身宫, and 空亡. These are deterministic
/// outputs of the BaZi rules for the given pillars.
@Suite("Chart analysis")
struct BaziChartAnalysisTests {
    private struct Case {
        let pillars: [String]
        let stemTenGods: [String] // year, month, hour
        let hiddenTenGods: [[String]] // year, month, day, hour
        let naYin: [String]
        let growthStages: [String]
        let taiYuan: String
        let mingGong: String
        let shenGong: String
        let voids: String
    }

    private let cases: [Case] = [
        Case(
            pillars: ["乙亥", "壬午", "丁丑", "甲辰"],
            stemTenGods: ["偏印", "正官", "正印"],
            hiddenTenGods: [["正官", "正印"], ["比肩", "食神"], ["食神", "七杀", "偏财"], ["伤官", "偏印", "七杀"]],
            naYin: ["山头火", "杨柳木", "涧下水", "覆灯火"],
            growthStages: ["胎", "临官", "墓", "衰"],
            taiYuan: "癸酉", mingGong: "癸未", shenGong: "丁亥", voids: "申酉"
        ),
        Case(
            pillars: ["己卯", "丁丑", "甲子", "庚午"],
            stemTenGods: ["正财", "伤官", "七杀"],
            hiddenTenGods: [["劫财"], ["正财", "正印", "正官"], ["正印"], ["伤官", "正财"]],
            naYin: ["城头土", "涧下水", "海中金", "路旁土"],
            growthStages: ["帝旺", "冠带", "沐浴", "死"],
            taiYuan: "戊辰", mingGong: "甲戌", shenGong: "壬申", voids: "戌亥"
        ),
        Case(
            pillars: ["戊子", "庚申", "庚辰", "丙戌"],
            stemTenGods: ["偏印", "比肩", "七杀"],
            hiddenTenGods: [["伤官"], ["比肩", "食神", "偏印"], ["偏印", "正财", "伤官"], ["偏印", "劫财", "正官"]],
            naYin: ["霹雳火", "石榴木", "白蜡金", "屋上土"],
            growthStages: ["死", "临官", "养", "衰"],
            taiYuan: "辛亥", mingGong: "癸亥", shenGong: "己未", voids: "申酉"
        ),
        Case(
            pillars: ["丁巳", "己酉", "庚辰", "戊寅"],
            stemTenGods: ["正官", "正印", "偏印"],
            hiddenTenGods: [["七杀", "比肩", "偏印"], ["劫财"], ["偏印", "正财", "伤官"], ["偏财", "七杀", "偏印"]],
            naYin: ["沙中土", "大驿土", "白蜡金", "城头土"],
            growthStages: ["长生", "帝旺", "养", "绝"],
            taiYuan: "庚子", mingGong: "丙午", shenGong: "壬子", voids: "申酉"
        ),
        Case(
            pillars: ["己亥", "庚午", "壬寅", "戊申"],
            stemTenGods: ["正官", "偏印", "七杀"],
            hiddenTenGods: [["比肩", "食神"], ["正财", "正官"], ["食神", "偏财", "七杀"], ["偏印", "比肩", "七杀"]],
            naYin: ["平地木", "路旁土", "金箔金", "大驿土"],
            growthStages: ["临官", "胎", "病", "长生"],
            taiYuan: "辛酉", mingGong: "丁卯", shenGong: "丁卯", voids: "辰巳"
        )
    ]

    private func cycle(_ chinese: String) -> SexagenaryCycle {
        let index = (0..<60).first { SexagenaryCycle(index: $0).chinese == chinese } ?? 0
        return SexagenaryCycle(index: index)
    }

    private func chart(_ pillars: [String]) throws -> BaziChart {
        let moment = try CivilMoment(year: 2000, month: 1, day: 7, hour: 12, minute: 0, timeZoneIdentifier: "UTC")
        return BaziChart(
            input: BirthInput(moment: moment),
            ruleSet: .professionalDefault,
            fourPillars: FourPillars(
                year: Pillar(kind: .year, cycle: cycle(pillars[0])),
                month: Pillar(kind: .month, cycle: cycle(pillars[1])),
                day: Pillar(kind: .day, cycle: cycle(pillars[2])),
                hour: Pillar(kind: .hour, cycle: cycle(pillars[3]))
            ),
            trace: ComputationTrace(provider: .algorithmic, confidence: .unchecked)
        )
    }

    @Test func derivesAllStructures() throws {
        for testCase in cases {
            let analysis = try chart(testCase.pillars).analysis()

            // Stem ten gods (year, month, hour; day is the day master).
            #expect(analysis.year.stemTenGod?.chinese == testCase.stemTenGods[0], "\(testCase.pillars) year ten god")
            #expect(analysis.month.stemTenGod?.chinese == testCase.stemTenGods[1], "\(testCase.pillars) month ten god")
            #expect(analysis.hour.stemTenGod?.chinese == testCase.stemTenGods[2], "\(testCase.pillars) hour ten god")
            #expect(analysis.day.stemTenGod == nil)

            for (index, pillar) in analysis.pillars.enumerated() {
                #expect(pillar.hiddenStemTenGods.map(\.chinese) == testCase.hiddenTenGods[index], "\(testCase.pillars) hidden \(index)")
                #expect(pillar.naYin.chinese == testCase.naYin[index], "\(testCase.pillars) nayin \(index)")
                #expect(pillar.growthStage.chinese == testCase.growthStages[index], "\(testCase.pillars) growth \(index)")
            }

            let palaces = analysis.palaces
            #expect(palaces.fetalOrigin.chinese == testCase.taiYuan, "\(testCase.pillars) 胎元")
            #expect(palaces.lifePalace.chinese == testCase.mingGong, "\(testCase.pillars) 命宫")
            #expect(palaces.bodyPalace.chinese == testCase.shenGong, "\(testCase.pillars) 身宫")

            #expect(Set(analysis.voidBranches.branches.map(\.chinese)) == Set(testCase.voids.map(String.init)), "\(testCase.pillars) 空亡")
        }
    }

    @Test func bundlesEveryDerivedStructure() throws {
        let analysis = try chart(["乙亥", "壬午", "丁丑", "甲辰"]).analysis()
        #expect(analysis.pillars.count == 4)
        #expect(analysis.dayMaster == .ding)
        #expect(analysis.year.kind == .year)
        #expect(analysis.day.stemTenGod == nil)
        #expect(analysis.fiveElements.count(of: .fire) >= 1)
        #expect(!analysis.shenSha.isEmpty)
        // 天乙贵人 for a 丁 day master lands on the 亥 year branch.
        #expect(analysis.shenSha(on: .year).contains { $0.displayName == "天乙贵人" })
    }
}
