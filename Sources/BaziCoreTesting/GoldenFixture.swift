import BaziCore
import Foundation

/// A golden fixture: a birth input and rule set with expected pillars and optional luck cycle.
public struct GoldenFixture: Codable, Equatable, Sendable {
    public var id: String
    public var input: FixtureInput
    public var ruleSet: FixtureRuleSet?
    public var expected: FixturePillars
    public var expectedLuck: FixtureLuck?
    public var sources: [String]
    public var confidence: BaziValidationConfidence?
    public var notes: [String]

    public init(
        id: String,
        input: FixtureInput,
        ruleSet: FixtureRuleSet? = nil,
        expected: FixturePillars,
        expectedLuck: FixtureLuck? = nil,
        sources: [String] = [],
        confidence: BaziValidationConfidence? = nil,
        notes: [String] = []
    ) {
        self.id = id
        self.input = input
        self.ruleSet = ruleSet
        self.expected = expected
        self.expectedLuck = expectedLuck
        self.sources = sources
        self.confidence = confidence
        self.notes = notes
    }

    /// Builds the birth input encoded by this fixture.
    public func birthInput() throws(BaziError) -> BirthInput {
        let moment = try CivilMoment(
            year: input.year, month: input.month, day: input.day,
            hour: input.hour, minute: input.minute, second: input.second ?? 0,
            timeZoneIdentifier: input.timeZone
        )
        let location: CalculationLocation? = (input.longitude != nil || input.latitude != nil)
            ? CalculationLocation(latitude: input.latitude, longitude: input.longitude)
            : nil
        return BirthInput(
            moment: moment,
            location: location,
            sexForLuckCycle: input.sex.flatMap(SexForLuckCycle.init(rawValue:))
        )
    }

    /// Builds the rule set encoded by this fixture, defaulting to professional.
    public func baziRuleSet() -> BaziRuleSet {
        var rules = BaziRuleSet.professionalDefault
        guard let ruleSet else { return rules }
        if let value = ruleSet.yearBoundary.flatMap(YearBoundaryRule.init(rawValue:)) { rules.yearBoundary = value }
        if let value = ruleSet.monthBoundary.flatMap(MonthBoundaryRule.init(rawValue:)) { rules.monthBoundary = value }
        if let value = ruleSet.dayBoundary.flatMap(DayBoundaryRule.init(rawValue:)) { rules.dayBoundary = value }
        if let value = ruleSet.ziHourPolicy.flatMap(ZiHourPolicy.init(rawValue:)) { rules.ziHourPolicy = value }
        if let value = ruleSet.timeCorrection.flatMap(TimeCorrectionPolicy.init(rawValue:)) { rules.timeCorrection = value }
        if let value = ruleSet.pillarTimeBasis.flatMap(PillarTimeBasis.init(rawValue:)) { rules.pillarTimeBasis = value }
        return rules
    }
}

/// The birth input block of a fixture.
public struct FixtureInput: Codable, Equatable, Sendable {
    public var calendar: String
    public var year: Int
    public var month: Int
    public var day: Int
    public var hour: Int
    public var minute: Int
    public var second: Int?
    public var timeZone: String
    public var longitude: Double?
    public var latitude: Double?
    public var sex: String?

    public init(
        calendar: String = "gregorian",
        year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int? = nil,
        timeZone: String, longitude: Double? = nil, latitude: Double? = nil, sex: String? = nil
    ) {
        self.calendar = calendar
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.timeZone = timeZone
        self.longitude = longitude
        self.latitude = latitude
        self.sex = sex
    }
}

/// Rule-set overrides for a fixture; any omitted field uses the professional default.
public struct FixtureRuleSet: Codable, Equatable, Sendable {
    public var yearBoundary: String?
    public var monthBoundary: String?
    public var dayBoundary: String?
    public var ziHourPolicy: String?
    public var timeCorrection: String?
    public var pillarTimeBasis: String?

    public init(
        yearBoundary: String? = nil, monthBoundary: String? = nil, dayBoundary: String? = nil,
        ziHourPolicy: String? = nil, timeCorrection: String? = nil, pillarTimeBasis: String? = nil
    ) {
        self.yearBoundary = yearBoundary
        self.monthBoundary = monthBoundary
        self.dayBoundary = dayBoundary
        self.ziHourPolicy = ziHourPolicy
        self.timeCorrection = timeCorrection
        self.pillarTimeBasis = pillarTimeBasis
    }
}

/// Expected four-pillar GanZhi strings.
public struct FixturePillars: Codable, Equatable, Sendable {
    public var year: String
    public var month: String
    public var day: String
    public var hour: String

    public init(year: String, month: String, day: String, hour: String) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
    }
}

/// Optional luck-cycle expectations for a fixture.
public struct FixtureLuck: Codable, Equatable, Sendable {
    public var direction: String
    public var childLimitYears: Int
    public var childLimitMonths: Int
    public var firstDaYun: String?

    public init(direction: String, childLimitYears: Int, childLimitMonths: Int, firstDaYun: String? = nil) {
        self.direction = direction
        self.childLimitYears = childLimitYears
        self.childLimitMonths = childLimitMonths
        self.firstDaYun = firstDaYun
    }
}
