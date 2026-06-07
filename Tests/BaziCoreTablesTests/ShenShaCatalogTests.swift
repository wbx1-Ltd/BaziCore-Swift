import BaziCore
@testable import BaziCoreTables
import Foundation
import Testing

@Suite("ShenSha catalog")
struct ShenShaCatalogTests {
    private func chart(year: Int, month: Int, day: Int, hour: Int) throws -> BaziChart {
        let moment = try CivilMoment(
            year: 2000, month: 1, day: 7, hour: 12, minute: 0, timeZoneIdentifier: "UTC"
        )
        return BaziChart(
            input: BirthInput(moment: moment),
            ruleSet: .professionalDefault,
            fourPillars: FourPillars(
                year: Pillar(kind: .year, cycle: SexagenaryCycle(index: year)),
                month: Pillar(kind: .month, cycle: SexagenaryCycle(index: month)),
                day: Pillar(kind: .day, cycle: SexagenaryCycle(index: day)),
                hour: Pillar(kind: .hour, cycle: SexagenaryCycle(index: hour))
            ),
            trace: ComputationTrace(provider: .algorithmic, confidence: .unchecked)
        )
    }

    /// 乙亥 壬午 丁丑 甲辰 — day master 丁.
    private func sampleChart() throws -> BaziChart {
        try chart(year: 11, month: 18, day: 13, hour: 40)
    }

    private func hits(_ rule: CommonShenShaRule) throws -> [(PillarKind, EarthlyBranch)] {
        try rule.evaluate(chart: sampleChart()).map { ($0.pillar, $0.branch) }
    }

    @Test func tianYiGuiRenLandsOnNobleBranch() throws {
        // 丁 day master -> 天乙 at 亥酉; the year branch 亥 qualifies.
        let result = try hits(.tianYiGuiRen)
        #expect(result.contains { $0 == (.year, .hai) })
    }

    @Test func luShenIsLinGuanBranch() throws {
        // 丁 禄 在 午; the month branch 午 qualifies.
        #expect(try hits(.luShen).contains { $0 == (.month, .wu) })
    }

    @Test func taoHuaFromReferenceBranch() throws {
        // 亥 (wood group) and 丑 (metal group) -> 桃花 子/午; month 午 qualifies.
        #expect(try hits(.taoHua).contains { $0 == (.month, .wu) })
    }

    @Test func yiMaAndHuaGaiAndHongLuan() throws {
        #expect(try hits(.yiMa).contains { $0 == (.year, .hai) })
        #expect(try hits(.huaGai).contains { $0 == (.day, .chou) })
        #expect(try hits(.hongLuan).contains { $0 == (.hour, .chen) })
    }

    @Test func yangRenOnlyForYangDayStems() throws {
        // 丁 is Yin, so 羊刃 produces nothing here.
        #expect(try hits(.yangRen).isEmpty)
        // 甲 day master (index 0 = 甲子) has 羊刃 at 卯.
        let jiaChart = try chart(year: 0, month: 3, day: 0, hour: 0) // month 丁卯 has 卯
        let result = CommonShenShaRule.yangRen.evaluate(chart: jiaChart)
        #expect(result.contains { $0.branch == .mao && $0.pillar == .month })
    }

    @Test func luShenTableForEveryStem() {
        let expected: [(HeavenlyStem, EarthlyBranch)] = [
            (.jia, .yin), (.yi, .mao), (.bing, .si), (.ding, .wu), (.wu, .si),
            (.ji, .wu), (.geng, .shen), (.xin, .you), (.ren, .hai), (.gui, .zi)
        ]
        for (stem, branch) in expected {
            // 禄 is the 临官 branch; verify via the growth-stage table directly.
            #expect(TwelveGrowthStageTable.stage(of: stem, at: branch) == .linGuan)
        }
    }

    @Test func tianYiTableForEveryStem() throws {
        // Each stem's 天乙 branches, by placing them on the hour branch.
        let expected: [HeavenlyStem: Set<EarthlyBranch>] = [
            .jia: [.chou, .wei], .wu: [.chou, .wei], .geng: [.chou, .wei],
            .yi: [.zi, .shen], .ji: [.zi, .shen],
            .bing: [.hai, .you], .ding: [.hai, .you],
            .ren: [.mao, .si], .gui: [.mao, .si],
            .xin: [.yin, .wu]
        ]
        for (stem, branches) in expected {
            // Cycle index 0...9 has stem 甲...癸, so day pillar stem == `stem`.
            let built = try chart(year: 0, month: 0, day: stem.rawValue, hour: 0)
            let targets = CommonShenShaRule.tianYiGuiRen.targetBranches(in: built)
            #expect(targets == branches)
        }
    }

    @Test func everyHitIdentifiesPillarAndBranch() throws {
        let hits = try ShenShaCatalog.ziPingCommon.evaluate(chart: sampleChart())
        #expect(!hits.isEmpty)
        let pillars = try sampleChart().fourPillars
        for hit in hits {
            let pillar = pillars.all.first { $0.kind == hit.pillar }
            #expect(pillar?.branch == hit.branch)
            #expect(hit.source == .ziPingClassic)
        }
    }
}
