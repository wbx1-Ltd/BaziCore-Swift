import BaziCore
import Testing

@Suite("Solar term classification")
struct SolarTermClassificationTests {
    @Test func twelveJieAndTwelveZhongQi() {
        #expect(SolarTermKind.allCases.count(where: { $0.category == .jie }) == 12)
        #expect(SolarTermKind.allCases.count(where: { $0.category == .zhongQi }) == 12)
        #expect(SolarTermKind.liChun.category == .jie)
        #expect(SolarTermKind.yuShui.category == .zhongQi)
        // The Jie terms are exactly the month-boundary terms.
        for term in SolarTermKind.allCases {
            #expect((term.category == .jie) == term.isMonthBoundaryTerm)
        }
    }

    @Test func seasonsHaveSixTermsEach() {
        for season in Season.allCases {
            #expect(SolarTermKind.allCases.count(where: { $0.season == season }) == 6)
        }
        #expect(SolarTermKind.liChun.season == .spring)
        #expect(SolarTermKind.chunFen.season == .spring)
        #expect(SolarTermKind.liXia.season == .summer)
        #expect(SolarTermKind.liQiu.season == .autumn)
        #expect(SolarTermKind.liDong.season == .winter)
        #expect(SolarTermKind.xiaoHan.season == .winter)
        #expect(SolarTermKind.daHan.season == .winter)
    }

    @Test func cardinalMarkers() {
        #expect(SolarTermKind.allCases.filter(\.isSeasonStart) == [.liChun, .liXia, .liQiu, .liDong])
        #expect(SolarTermKind.chunFen.isEquinox)
        #expect(SolarTermKind.qiuFen.isEquinox)
        #expect(SolarTermKind.xiaZhi.isSolstice)
        #expect(SolarTermKind.dongZhi.isSolstice)
        #expect(!SolarTermKind.liChun.isEquinox)
        #expect(!SolarTermKind.chunFen.isSolstice)
    }
}
