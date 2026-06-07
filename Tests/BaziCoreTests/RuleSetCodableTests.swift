import BaziCore
import Foundation
import Testing

@Suite("Rule set Codable & Hashable")
struct RuleSetCodableTests {
    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        let data = try JSONEncoder().encode(value)
        return try JSONDecoder().decode(T.self, from: data)
    }

    @Test func professionalDefaultHasExpectedRules() {
        let rules = BaziRuleSet.professionalDefault
        #expect(rules.yearBoundary == .liChunExact)
        #expect(rules.monthBoundary == .jieExact)
        #expect(rules.dayBoundary == .civilMidnight)
        #expect(rules.ziHourPolicy == .lateZiNextDay)
        #expect(rules.timeCorrection == .standardClock)
        #expect(rules.pillarTimeBasis == .astronomicalInstantForTerms)
        #expect(rules.childLimitRule == .threeDaysPerYear)
        #expect(rules.shenShaCatalog == .ziPingCommon)
    }

    @Test func ruleSetRoundTrips() throws {
        let rules = BaziRuleSet(
            yearBoundary: .lunarNewYear,
            monthBoundary: .jieExact,
            dayBoundary: .ziHourStart,
            ziHourPolicy: .lateZiSameDay,
            timeCorrection: .trueSolarTime,
            pillarTimeBasis: .correctedLocalMomentForAllPillars,
            childLimitRule: .threeDaysPerYear,
            shenShaCatalog: .ziPingCommon
        )
        #expect(try roundTrip(rules) == rules)
    }

    @Test func everyRuleEnumRoundTrips() throws {
        for value in YearBoundaryRule.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in MonthBoundaryRule.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in DayBoundaryRule.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in ZiHourPolicy.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in TimeCorrectionPolicy.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in PillarTimeBasis.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in ChildLimitRule.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in ShenShaCatalogIdentifier.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in RepeatedTimeResolution.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in SexForLuckCycle.allCases {
            #expect(try roundTrip(value) == value)
        }
        for value in BirthInputCalendar.allCases {
            #expect(try roundTrip(value) == value)
        }
    }

    @Test func ruleEnumsEncodeAsStableRawStrings() throws {
        let data = try JSONEncoder().encode(YearBoundaryRule.liChunExact)
        #expect(String(bytes: data, encoding: .utf8) == "\"liChunExact\"")
    }

    @Test func birthInputRoundTrips() throws {
        let moment = try CivilMoment(
            year: 1990, month: 6, day: 15, hour: 8, minute: 30, second: 0,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let input = BirthInput(
            moment: moment,
            location: CalculationLocation(identifier: "Beijing", latitude: 39.9042, longitude: 116.4074),
            sexForLuckCycle: .male
        )
        #expect(try roundTrip(input) == input)
    }
}
