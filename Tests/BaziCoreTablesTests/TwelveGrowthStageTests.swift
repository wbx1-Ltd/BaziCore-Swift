import BaziCore
import BaziCoreTables
import Testing

@Suite("Twelve growth stages (十二长生)")
struct TwelveGrowthStageTests {
    @Test func jiaProgressesForwardFromHai() {
        // 甲 (Yang Wood): 长生 在 亥, advancing forward through the branches.
        #expect(TwelveGrowthStageTable.stage(of: .jia, at: .hai) == .changSheng)
        #expect(TwelveGrowthStageTable.stage(of: .jia, at: .zi) == .muYu)
        #expect(TwelveGrowthStageTable.stage(of: .jia, at: .yin) == .linGuan)
        #expect(TwelveGrowthStageTable.stage(of: .jia, at: .mao) == .diWang)
        #expect(TwelveGrowthStageTable.stage(of: .jia, at: .wu) == .si)
    }

    @Test func yiProgressesBackwardFromWu() {
        // 乙 (Yin Wood): 长生 在 午, advancing backward through the branches.
        #expect(TwelveGrowthStageTable.stage(of: .yi, at: .wu) == .changSheng)
        #expect(TwelveGrowthStageTable.stage(of: .yi, at: .si) == .muYu)
        #expect(TwelveGrowthStageTable.stage(of: .yi, at: .yin) == .diWang)
    }

    @Test func everyStemVisitsAllTwelveStages() {
        for stem in HeavenlyStem.allCases {
            let stages = EarthlyBranch.allCases.map { TwelveGrowthStageTable.stage(of: stem, at: $0) }
            #expect(Set(stages).count == 12)
        }
    }

    @Test func growthOrigins() {
        #expect(TwelveGrowthStageTable.growthOrigin(of: .bing) == .yin)
        #expect(TwelveGrowthStageTable.growthOrigin(of: .geng) == .si)
        #expect(TwelveGrowthStageTable.growthOrigin(of: .ren) == .shen)
        #expect(TwelveGrowthStageTable.growthOrigin(of: .gui) == .mao)
    }
}
