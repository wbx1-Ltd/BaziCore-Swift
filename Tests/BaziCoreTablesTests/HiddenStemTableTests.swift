import BaziCore
import BaziCoreTables
import Testing

@Suite("Hidden stem table")
struct HiddenStemTableTests {
    @Test func tableMatchesCanonicalOrdering() {
        let expected: [EarthlyBranch: [HeavenlyStem]] = [
            .zi: [.gui],
            .chou: [.ji, .gui, .xin],
            .yin: [.jia, .bing, .wu],
            .mao: [.yi],
            .chen: [.wu, .yi, .gui],
            .si: [.bing, .geng, .wu],
            .wu: [.ding, .ji],
            .wei: [.ji, .ding, .yi],
            .shen: [.geng, .ren, .wu],
            .you: [.xin],
            .xu: [.wu, .xin, .ding],
            .hai: [.ren, .jia]
        ]
        for branch in EarthlyBranch.allCases {
            let stems = HiddenStemTable.hiddenStems(of: branch).map(\.stem)
            #expect(stems == expected[branch])
        }
    }

    @Test func primaryQiIsFirst() {
        for branch in EarthlyBranch.allCases {
            let hidden = HiddenStemTable.hiddenStems(of: branch)
            #expect(hidden.first?.role == .primaryQi)
        }
    }

    @Test func weightsFollowConvention() {
        #expect(HiddenStemTable.hiddenStems(of: .zi).map(\.weight) == [100])
        #expect(HiddenStemTable.hiddenStems(of: .wu).map(\.weight) == [70, 30])
        #expect(HiddenStemTable.hiddenStems(of: .yin).map(\.weight) == [60, 30, 10])
    }

    @Test func weightsSumToOneHundred() {
        for branch in EarthlyBranch.allCases {
            let total = HiddenStemTable.hiddenStems(of: branch).map(\.weight).reduce(0, +)
            #expect(total == 100)
        }
    }
}
