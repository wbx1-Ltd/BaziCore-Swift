import BaziCore
import Foundation
import Testing

@Suite("Stem, branch, and sexagenary cycle")
struct SexagenaryCycleTests {
    @Test func stemIndexWrapsCyclically() {
        #expect(HeavenlyStem(normalizedIndex: 0) == .jia)
        #expect(HeavenlyStem(normalizedIndex: 10) == .jia)
        #expect(HeavenlyStem(normalizedIndex: -1) == .gui)
        #expect(HeavenlyStem(normalizedIndex: 11) == .yi)
    }

    @Test func branchIndexWrapsCyclically() {
        #expect(EarthlyBranch(normalizedIndex: 0) == .zi)
        #expect(EarthlyBranch(normalizedIndex: 12) == .zi)
        #expect(EarthlyBranch(normalizedIndex: -1) == .hai)
    }

    @Test func cycleIndexRoundTrips() {
        for index in 0..<60 {
            let cycle = SexagenaryCycle(index: index)
            #expect(cycle.index == index)
        }
    }

    @Test func knownPairs() {
        #expect(SexagenaryCycle(index: 0).chinese == "甲子")
        #expect(SexagenaryCycle(index: 59).chinese == "癸亥")
        #expect(SexagenaryCycle(index: 1).chinese == "乙丑")
    }

    @Test func invalidParityPairRejected() {
        // 甲 (even, 0) with 丑 (odd, 1) never occurs in the cycle.
        #expect(SexagenaryCycle(stem: .jia, branch: .chou) == nil)
        #expect(SexagenaryCycle(stem: .jia, branch: .zi) != nil)
    }

    @Test func advanceWrapsForwardAndBackward() {
        let jiaZi = SexagenaryCycle(index: 0)
        #expect(jiaZi.advanced(by: 1).chinese == "乙丑")
        #expect(jiaZi.advanced(by: -1).chinese == "癸亥")
        #expect(jiaZi.advanced(by: 60).chinese == "甲子")
    }

    @Test func solarTermLongitudesMatchHko() {
        #expect(SolarTermKind.chunFen.solarLongitude == 0)
        #expect(SolarTermKind.qingMing.solarLongitude == 15)
        #expect(SolarTermKind.dongZhi.solarLongitude == 270)
        #expect(SolarTermKind.liChun.solarLongitude == 315)
    }

    @Test func twelveJieTermsMapToMonths() {
        let jie = SolarTermKind.allCases.filter(\.isMonthBoundaryTerm)
        #expect(jie.count == 12)
        #expect(SolarTermKind.liChun.baziMonthNumber == 1)
        #expect(SolarTermKind.liChun.baziMonthBranch == .yin)
        #expect(SolarTermKind.daXue.baziMonthNumber == 11)
        #expect(SolarTermKind.daXue.baziMonthBranch == .zi)
        #expect(SolarTermKind.xiaoHan.baziMonthNumber == 12)
        #expect(SolarTermKind.xiaoHan.baziMonthBranch == .chou)
        #expect(SolarTermKind.chunFen.baziMonthNumber == nil)
    }
}
