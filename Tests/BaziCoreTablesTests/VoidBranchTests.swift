import BaziCore
import BaziCoreTables
import Testing

@Suite("Void branches (空亡)")
struct VoidBranchTests {
    @Test func allSixDecades() {
        let expected: [(index: Int, voids: [EarthlyBranch])] = [
            (0, [.xu, .hai]), // 甲子旬
            (10, [.shen, .you]), // 甲戌旬
            (20, [.wu, .wei]), // 甲申旬
            (30, [.chen, .si]), // 甲午旬
            (40, [.yin, .mao]), // 甲辰旬
            (50, [.zi, .chou]) // 甲寅旬
        ]
        for (index, voids) in expected {
            let result = VoidBranch.forPillar(SexagenaryCycle(index: index))
            #expect(result.branches == voids)
            #expect(result.decadeIndex == index / 10)
        }
    }

    @Test func consistentWithinDecade() {
        // 甲子 (0) and 癸酉 (9) are in the same decade, so share void branches.
        let first = VoidBranch.forPillar(SexagenaryCycle(index: 0))
        let last = VoidBranch.forPillar(SexagenaryCycle(index: 9))
        #expect(first.branches == last.branches)
    }

    @Test func containsVoidBranch() {
        let result = VoidBranch.forPillar(SexagenaryCycle(index: 0))
        #expect(result.contains(.xu))
        #expect(result.contains(.hai))
        #expect(!result.contains(.zi))
    }
}
