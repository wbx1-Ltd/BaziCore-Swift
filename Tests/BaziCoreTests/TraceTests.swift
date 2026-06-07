import BaziCore
import Foundation
import Testing

@Suite("Pillar, chart, and trace models")
struct TraceTests {
    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        let data = try JSONEncoder().encode(value)
        return try JSONDecoder().decode(T.self, from: data)
    }

    @Test func pillarExposesComponents() {
        let pillar = Pillar(kind: .day, cycle: SexagenaryCycle(index: 0))
        #expect(pillar.stem == .jia)
        #expect(pillar.branch == .zi)
        #expect(pillar.ganZhiIndex == 0)
        #expect(pillar.chinese == "甲子")
        #expect(pillar.kind.chineseName == "日柱")
    }

    @Test func pillarRoundTrips() throws {
        let pillar = Pillar(kind: .hour, cycle: SexagenaryCycle(index: 13))
        #expect(try roundTrip(pillar) == pillar)
    }

    @Test func fourPillarsDeriveDayMasterAndRendering() {
        let pillars = FourPillars(
            year: Pillar(kind: .year, cycle: SexagenaryCycle(index: 0)), // 甲子
            month: Pillar(kind: .month, cycle: SexagenaryCycle(index: 2)), // 丙寅
            day: Pillar(kind: .day, cycle: SexagenaryCycle(index: 54)), // 戊午
            hour: Pillar(kind: .hour, cycle: SexagenaryCycle(index: 58)) // 壬戌
        )
        #expect(pillars.dayMaster == .wu)
        #expect(pillars.all.count == 4)
        #expect(pillars.chinese == "甲子 丙寅 戊午 壬戌")
    }

    @Test func traceCollectsNotesAndDetails() {
        var trace = ComputationTrace(provider: .astronomy, confidence: .canonical)
        trace.add(.birthAtOrAfterLiChun)
        trace.add(.yearBoundaryLiChunExact)
        trace.add(
            .liChunInstant,
            value: "2025-02-03T22:10:00Z",
            date: Date(timeIntervalSinceReferenceDate: 12345)
        )
        #expect(trace.notes == [.birthAtOrAfterLiChun, .yearBoundaryLiChunExact])
        #expect(trace.details.count == 1)
        #expect(trace.details.first?.key == .liChunInstant)
    }

    @Test func traceRoundTrips() throws {
        let trace = ComputationTrace(
            provider: .hybrid,
            confidence: .providerVerified,
            notes: [.birthBeforeLiChun, .lateZiHourRolledToNextDay],
            details: [
                BaziTraceDetail(key: .effectiveDay, value: "2000-01-07"),
                BaziTraceDetail(
                    key: .liChunInstant,
                    value: "instant",
                    date: Date(timeIntervalSinceReferenceDate: 98765)
                )
            ],
            sourceReferences: ["bazicore"]
        )
        #expect(try roundTrip(trace) == trace)
    }

    @Test func chartRoundTrips() throws {
        let moment = try CivilMoment(
            year: 2000, month: 1, day: 7, hour: 12, minute: 0,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let chart = BaziChart(
            input: BirthInput(moment: moment, sexForLuckCycle: .female),
            ruleSet: .professionalDefault,
            fourPillars: FourPillars(
                year: Pillar(kind: .year, cycle: SexagenaryCycle(index: 16)),
                month: Pillar(kind: .month, cycle: SexagenaryCycle(index: 13)),
                day: Pillar(kind: .day, cycle: SexagenaryCycle(index: 0)),
                hour: Pillar(kind: .hour, cycle: SexagenaryCycle(index: 6))
            ),
            trace: ComputationTrace(provider: .algorithmic, confidence: .canonical)
        )
        #expect(chart.dayMaster == .jia)
        #expect(try roundTrip(chart) == chart)
    }
}
