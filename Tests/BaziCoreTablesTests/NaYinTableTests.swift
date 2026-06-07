import BaziCore
import BaziCoreTables
import Testing

@Suite("NaYin table")
struct NaYinTableTests {
    @Test func knownEntries() {
        #expect(NaYinTable.naYin(forCycleIndex: 0).chinese == "海中金")
        #expect(NaYinTable.naYin(forCycleIndex: 1).chinese == "海中金")
        #expect(NaYinTable.naYin(forCycleIndex: 2).chinese == "炉中火")
        #expect(NaYinTable.naYin(forCycleIndex: 4).chinese == "大林木")
        #expect(NaYinTable.naYin(forCycleIndex: 58).chinese == "大海水")
        #expect(NaYinTable.naYin(forCycleIndex: 59).chinese == "大海水")
    }

    @Test func pairsShareNaYin() {
        // Each NaYin spans two consecutive cycle positions.
        for index in stride(from: 0, to: 60, by: 2) {
            #expect(NaYinTable.naYin(forCycleIndex: index) == NaYinTable.naYin(forCycleIndex: index + 1))
        }
    }

    @Test func thirtyDistinctValues() {
        let names = Set((0..<60).map { NaYinTable.naYin(forCycleIndex: $0).chinese })
        #expect(names.count == 30)
    }

    @Test func elementMatchesLastCharacter() throws {
        let mapping: [Character: Element] = ["金": .metal, "木": .wood, "水": .water, "火": .fire, "土": .earth]
        for index in 0..<60 {
            let naYin = NaYinTable.naYin(forCycleIndex: index)
            #expect(try naYin.element == mapping[#require(naYin.chinese.last)])
        }
    }

    @Test func indexWraps() {
        #expect(NaYinTable.naYin(forCycleIndex: 60) == NaYinTable.naYin(forCycleIndex: 0))
        #expect(NaYinTable.naYin(for: SexagenaryCycle(index: 0)).chinese == "海中金")
    }
}
