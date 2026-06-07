import BaziCore
import BaziCoreTables
import Foundation
import Testing

@Suite("Five element profile")
struct FiveElementProfileTests {
    /// 甲子 / 丙寅 / 戊午 / 壬戌 — chosen so every element is hand-verifiable.
    private let pillars = FourPillars(
        year: Pillar(kind: .year, cycle: SexagenaryCycle(index: 0)), // 甲子
        month: Pillar(kind: .month, cycle: SexagenaryCycle(index: 2)), // 丙寅
        day: Pillar(kind: .day, cycle: SexagenaryCycle(index: 54)), // 戊午
        hour: Pillar(kind: .hour, cycle: SexagenaryCycle(index: 58)) // 壬戌
    )

    @Test func stemAndBranchElements() {
        let profile = FiveElementProfile(fourPillars: pillars)
        #expect(profile.stemElements == [.wood, .fire, .earth, .water])
        #expect(profile.branchElements == [.water, .wood, .fire, .earth])
    }

    @Test func tallyExcludingHiddenStems() {
        let profile = FiveElementProfile(fourPillars: pillars)
        let tally = profile.tally(includingHiddenStems: false)
        #expect(tally[.wood] == 2)
        #expect(tally[.fire] == 2)
        #expect(tally[.earth] == 2)
        #expect(tally[.water] == 2)
        #expect(tally[.metal] == nil)
        #expect(profile.missingElements(includingHiddenStems: false) == [.metal])
    }

    @Test func tallyIncludingHiddenStems() {
        let profile = FiveElementProfile(fourPillars: pillars)
        #expect(profile.count(of: .wood) == 3)
        #expect(profile.count(of: .fire) == 5)
        #expect(profile.count(of: .earth) == 5)
        #expect(profile.count(of: .metal) == 1)
        #expect(profile.count(of: .water) == 3)
        #expect(profile.missingElements() == [])
        #expect(profile.dominantElements() == [.fire, .earth])
    }

    @Test func roundTripsThroughCodable() throws {
        let profile = FiveElementProfile(fourPillars: pillars)
        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(FiveElementProfile.self, from: data)
        #expect(decoded == profile)
    }
}
