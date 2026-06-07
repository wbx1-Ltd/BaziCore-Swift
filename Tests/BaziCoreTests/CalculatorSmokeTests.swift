import BaziCore
import BaziCoreAstronomy
import Foundation
import Testing

@Suite("Calculator smoke")
struct CalculatorSmokeTests {
    private let calculator = BaziCalculator(solarTermProvider: AstronomicalSolarTermProvider())

    private func chartString(
        _ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0,
        tz: String = "Asia/Shanghai"
    ) throws -> String {
        let moment = try CivilMoment(
            year: year, month: month, day: day, hour: hour, minute: minute, timeZoneIdentifier: tz
        )
        return try calculator.chart(for: BirthInput(moment: moment)).fourPillars.chinese
    }

    @Test func matchesIndependentCharts() throws {
        // Full charts from BaziCore (civil clock, professional default).
        #expect(try chartString(1990, 6, 15, 8, 30) == "庚午 壬午 辛亥 壬辰")
        #expect(try chartString(2000, 1, 7, 12) == "己卯 丁丑 甲子 庚午")
        #expect(try chartString(1977, 9, 20, 3, 15) == "丁巳 己酉 庚辰 戊寅")
        #expect(try chartString(2008, 8, 8, 20, 8) == "戊子 庚申 庚辰 丙戌")
    }

    @Test func liChunBoundaryChangesYearAndMonth() throws {
        #expect(try chartString(2025, 2, 3, 22, 9) == "甲辰 丁丑 癸卯 癸亥")
        #expect(try chartString(2025, 2, 3, 22, 11) == "乙巳 戊寅 癸卯 癸亥")
    }

    @Test func liChunWithinFebruaryNoonStaysPreviousYear() throws {
        // 立春 1984 falls after noon on 4 February, so noon is still 癸亥.
        #expect(try chartString(1984, 2, 4, 12) == "癸亥 乙丑 戊辰 戊午")
    }

    @Test func chartCarriesProvenance() throws {
        let moment = try CivilMoment(year: 1990, month: 6, day: 15, hour: 8, minute: 30, timeZoneIdentifier: "Asia/Shanghai")
        let chart = try calculator.chart(for: BirthInput(moment: moment))
        #expect(chart.dayMaster == .xin) // 辛亥 day -> 辛
        #expect(chart.trace.provider == .astronomy)
        #expect(chart.trace.confidence == .canonical)
        #expect(chart.trace.notes.contains(.yearBoundaryLiChunExact))
        #expect(chart.trace.notes.contains(.timeUsesStandardClock))
        #expect(chart.trace.notes.contains(.solarTermInstantHighPrecision))
    }

    @Test func chartUsesAdjacentMonthBoundaryLookup() throws {
        let provider = CountingSolarTermProvider()
        let calculator = BaziCalculator(solarTermProvider: provider)
        let moment = try CivilMoment(year: 2025, month: 3, day: 15, hour: 12, minute: 0, timeZoneIdentifier: "UTC")

        _ = try calculator.chart(for: BirthInput(moment: moment))

        #expect(provider.requests.count <= 3)
        #expect(provider.requests.contains(SolarTermRequest(term: .liChun, year: 2025)))
        #expect(provider.requests.contains(SolarTermRequest(term: .jingZhe, year: 2025)))
        #expect(!provider.requests.contains { $0.term == .qingMing })
    }

    @Test func chartRoundTripsThroughCodable() throws {
        let moment = try CivilMoment(year: 1990, month: 6, day: 15, hour: 8, minute: 30, timeZoneIdentifier: "Asia/Shanghai")
        let chart = try calculator.chart(for: BirthInput(moment: moment))
        let data = try JSONEncoder().encode(chart)
        let decoded = try JSONDecoder().decode(BaziChart.self, from: data)
        #expect(decoded == chart)
    }

    @Test func trueSolarTimeShiftsHourFarFromMeridian() throws {
        var rules = BaziRuleSet.professionalDefault
        rules.timeCorrection = .trueSolarTime
        let trueSolarCalculator = BaziCalculator(
            ruleSet: rules,
            solarTermProvider: AstronomicalSolarTermProvider(),
            timeCorrectionProvider: TrueSolarTimeEngine()
        )
        // Ürümqi (~87.6°E) on Beijing time: civil 14:00 is true-solar ~11:50,
        // moving the hour branch from 未 to 午.
        let moment = try CivilMoment(year: 1995, month: 6, day: 15, hour: 14, minute: 0, timeZoneIdentifier: "Asia/Shanghai")
        let input = BirthInput(moment: moment, location: CalculationLocation(longitude: 87.6))

        let standard = try calculator.chart(for: input)
        let corrected = try trueSolarCalculator.chart(for: input)

        #expect(standard.fourPillars.hour.branch == .wei)
        #expect(corrected.fourPillars.hour.branch == .wu)
        #expect(corrected.trace.notes.contains(.appliedTrueSolarTime))
        #expect(corrected.trace.provider == .hybrid)
        #expect(corrected.trace.details.contains { $0.key == .correctedLocalDateTime })
    }

    @Test func trueSolarTimeRequiresLocation() throws {
        var rules = BaziRuleSet.professionalDefault
        rules.timeCorrection = .trueSolarTime
        let trueSolarCalculator = BaziCalculator(
            ruleSet: rules,
            solarTermProvider: AstronomicalSolarTermProvider(),
            timeCorrectionProvider: TrueSolarTimeEngine()
        )
        let moment = try CivilMoment(
            year: 1995, month: 6, day: 15, hour: 14, minute: 0, timeZoneIdentifier: "Asia/Shanghai"
        )

        #expect(throws: BaziError.missingLocationForTimeCorrection(
            detail: "trueSolarTime correction requires a location with longitude"
        )) {
            try trueSolarCalculator.chart(for: BirthInput(moment: moment))
        }
    }

    @Test func trueSolarTimeRequiresProvider() throws {
        var rules = BaziRuleSet.professionalDefault
        rules.timeCorrection = .trueSolarTime
        let trueSolarCalculator = BaziCalculator(
            ruleSet: rules,
            solarTermProvider: AstronomicalSolarTermProvider()
        )
        let moment = try CivilMoment(
            year: 1995, month: 6, day: 15, hour: 14, minute: 0, timeZoneIdentifier: "Asia/Shanghai"
        )
        let input = BirthInput(moment: moment, location: CalculationLocation(longitude: 87.6))

        #expect(throws: BaziError.missingLocationForTimeCorrection(
            detail: "trueSolarTime correction requires a SolarTimeCorrectionProvider"
        )) {
            try trueSolarCalculator.chart(for: input)
        }
    }

    @Test func trueSolarTimeRejectsInvalidLongitude() throws {
        var rules = BaziRuleSet.professionalDefault
        rules.timeCorrection = .trueSolarTime
        let trueSolarCalculator = BaziCalculator(
            ruleSet: rules,
            solarTermProvider: AstronomicalSolarTermProvider(),
            timeCorrectionProvider: TrueSolarTimeEngine()
        )
        let moment = try CivilMoment(
            year: 1995, month: 6, day: 15, hour: 14, minute: 0, timeZoneIdentifier: "Asia/Shanghai"
        )
        let input = BirthInput(moment: moment, location: CalculationLocation(longitude: 999))

        #expect(throws: BaziError.invalidCoordinate(detail: "longitude 999.0 is outside -180...180")) {
            try trueSolarCalculator.chart(for: input)
        }
    }

    @Test func trueSolarTimeRejectsNonFiniteCoordinates() throws {
        var rules = BaziRuleSet.professionalDefault
        rules.timeCorrection = .trueSolarTime
        let trueSolarCalculator = BaziCalculator(
            ruleSet: rules,
            solarTermProvider: AstronomicalSolarTermProvider(),
            timeCorrectionProvider: TrueSolarTimeEngine()
        )
        let moment = try CivilMoment(
            year: 1995, month: 6, day: 15, hour: 14, minute: 0, timeZoneIdentifier: "Asia/Shanghai"
        )
        let input = BirthInput(moment: moment, location: CalculationLocation(latitude: .infinity, longitude: 120))

        #expect(throws: BaziError.invalidCoordinate(detail: "latitude inf is outside -90...90")) {
            try trueSolarCalculator.chart(for: input)
        }
    }
}

private struct SolarTermRequest: Equatable, Sendable {
    let term: SolarTermKind
    let year: Int
}

private final class CountingSolarTermProvider: SolarTermInstantProvider, @unchecked Sendable {
    private let lock = NSLock()
    private var recordedRequests: [SolarTermRequest] = []

    var requests: [SolarTermRequest] {
        lock.lock()
        defer { lock.unlock() }
        return recordedRequests
    }

    func solarTermInstant(_ term: SolarTermKind, gregorianYear year: Int) -> SolarTermInstant? {
        lock.lock()
        recordedRequests.append(SolarTermRequest(term: term, year: year))
        lock.unlock()

        let date: Date
        switch (term, year) {
        case (.liChun, 2025):
            date = utc(2025, 2, 4)
        case (.jingZhe, 2025):
            date = utc(2025, 3, 5)
        default:
            return nil
        }
        return SolarTermInstant(
            term: term,
            gregorianYear: year,
            date: date,
            julianDayUT: date.timeIntervalSince1970 / 86400.0 + 2440587.5
        )
    }

    var providerKind: BaziProviderKind { .algorithmic }

    private func utc(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
