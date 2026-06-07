import BaziCore
import BaziCoreTables
import Testing

@Suite("Ten god engine")
struct TenGodEngineTests {
    @Test func jiaDayMasterFullRow() {
        let dayMaster = HeavenlyStem.jia
        let expected: [(HeavenlyStem, TenGod)] = [
            (.jia, .biJian), (.yi, .jieCai),
            (.bing, .shiShen), (.ding, .shangGuan),
            (.wu, .pianCai), (.ji, .zhengCai),
            (.geng, .qiSha), (.xin, .zhengGuan),
            (.ren, .pianYin), (.gui, .zhengYin)
        ]
        for (target, god) in expected {
            #expect(TenGodEngine.tenGod(of: target, dayMaster: dayMaster) == god)
        }
    }

    @Test func selfRelationIsAlwaysBiJian() {
        for stem in HeavenlyStem.allCases {
            #expect(TenGodEngine.tenGod(of: stem, dayMaster: stem) == .biJian)
        }
    }

    @Test func fullMatrixIsConsistent() {
        // Every (dayMaster, target) pair resolves, and the polarity/element rules
        // hold across all 100 combinations.
        for dayMaster in HeavenlyStem.allCases {
            for target in HeavenlyStem.allCases {
                let god = TenGodEngine.tenGod(of: target, dayMaster: dayMaster)
                let samePolarity = dayMaster.yinYang == target.yinYang
                switch god {
                case .biJian, .shiShen, .pianCai, .qiSha, .pianYin:
                    #expect(samePolarity)
                case .jieCai, .shangGuan, .zhengCai, .zhengGuan, .zhengYin:
                    #expect(!samePolarity)
                }
            }
        }
    }

    @Test func wealthIsWhatDayMasterControls() {
        // 戊 (earth) day master controls water (壬癸) -> 财.
        #expect(TenGodEngine.tenGod(of: .ren, dayMaster: .wu) == .pianCai)
        #expect(TenGodEngine.tenGod(of: .gui, dayMaster: .wu) == .zhengCai)
    }

    @Test func hiddenStemTenGodsForBranch() {
        // 寅 hides 甲丙戊; relative to a 甲 day master that is 比肩, 食神, 偏财.
        let result = TenGodEngine.tenGods(ofHiddenStemsIn: .yin, dayMaster: .jia)
        #expect(result.map(\.tenGod) == [.biJian, .shiShen, .pianCai])
        #expect(result.map(\.hiddenStem.stem) == [.jia, .bing, .wu])
    }
}
