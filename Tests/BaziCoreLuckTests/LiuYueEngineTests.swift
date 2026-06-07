import BaziCore
import BaziCoreAstronomy
import BaziCoreLuck
import Foundation
import Testing

@Suite("LiuYue engine")
struct LiuYueEngineTests {
    private let provider = AstronomicalSolarTermProvider()

    @Test func twelveMonthsOfTheFleetingYear() throws {
        // 流年 2025 is 乙巳; its twelve months run 戊寅 … 戊子 … 己丑.
        let months = try LiuYueEngine.series(gregorianYear: 2025, provider: provider)
        #expect(months.count == 12)
        #expect(months.map(\.pillar.chinese) == [
            "戊寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
            "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑"
        ])
        #expect(months.map(\.monthNumber) == Array(1...12))
    }

    @Test func firstMonthOpensAtLiChun() throws {
        let months = try LiuYueEngine.series(gregorianYear: 2025, provider: provider)
        #expect(months[0].startTerm == .liChun)
        #expect(months[1].startTerm == .jingZhe)
        #expect(months[11].startTerm == .xiaoHan)
    }

    @Test func monthsAreContiguousAndChronological() throws {
        let months = try LiuYueEngine.series(gregorianYear: 2025, provider: provider)
        for index in 0..<months.count {
            #expect(months[index].endInstant > months[index].startInstant)
            if index > 0 {
                // Each month begins exactly where the previous one ended.
                #expect(months[index].startInstant == months[index - 1].endInstant)
            }
        }
    }

    @Test func prefetchesEachBoundaryOnlyOnce() throws {
        let provider = CountingSolarTermProvider { term, year in
            syntheticTermDate(term: term, year: year)
        }

        let months = try LiuYueEngine.series(gregorianYear: 2025, provider: provider)

        #expect(months.count == 12)
        #expect(provider.requestCount == 13)
        #expect(provider.requests.first == Request(term: .liChun, year: 2025))
        #expect(provider.requests.last == Request(term: .liChun, year: 2026))
    }

    @Test func missingBoundaryReportsActualMissingTerm() {
        let provider = StubSolarTermProvider { term, year in
            if term == .jingZhe, year == 2025 { return nil }
            return syntheticTermDate(term: term, year: year)
        }

        #expect(throws: BaziError.solarTermUnavailable(term: .jingZhe, year: 2025)) {
            try LiuYueEngine.series(gregorianYear: 2025, provider: provider)
        }
    }
}

private struct Request: Equatable, Sendable {
    let term: SolarTermKind
    let year: Int
}

private final class CountingSolarTermProvider: SolarTermInstantProvider, @unchecked Sendable {
    private let resolver: @Sendable (SolarTermKind, Int) -> Date?

    private let lock = NSLock()
    private var recordedRequests: [Request] = []

    var requests: [Request] {
        lock.lock()
        defer { lock.unlock() }
        return recordedRequests
    }

    var requestCount: Int { requests.count }

    init(resolver: @escaping @Sendable (SolarTermKind, Int) -> Date?) {
        self.resolver = resolver
    }

    func solarTermInstant(_ term: SolarTermKind, gregorianYear year: Int) -> SolarTermInstant? {
        lock.lock()
        recordedRequests.append(Request(term: term, year: year))
        lock.unlock()

        return resolver(term, year).map { date in
            SolarTermInstant(
                term: term,
                gregorianYear: year,
                date: date,
                julianDayUT: date.timeIntervalSince1970 / 86400.0 + 2440587.5
            )
        }
    }

    var providerKind: BaziProviderKind { .algorithmic }
}

private func syntheticTermDate(term: SolarTermKind, year: Int) -> Date {
    Date(timeIntervalSinceReferenceDate: Double(year - 2000) * 400 * 86400 + Double(term.rawValue) * 86400)
}
