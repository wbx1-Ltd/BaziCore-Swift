/// The full set of school-sensitive rules that govern a chart computation.
public struct BaziRuleSet: Codable, Hashable, Sendable {
    /// Where the year pillar changes over.
    public var yearBoundary: YearBoundaryRule
    /// Where the month pillar changes over.
    public var monthBoundary: MonthBoundaryRule
    /// Where the day pillar changes over.
    public var dayBoundary: DayBoundaryRule
    /// How the late-Zi hour maps to the day pillar.
    public var ziHourPolicy: ZiHourPolicy
    /// Whether and how to correct the civil clock to solar time.
    public var timeCorrection: TimeCorrectionPolicy
    /// How year/month boundaries are compared against the birth moment.
    public var pillarTimeBasis: PillarTimeBasis
    /// How the luck-cycle starting age is derived.
    public var childLimitRule: ChildLimitRule
    /// Which ShenSha catalog applies.
    public var shenShaCatalog: ShenShaCatalogIdentifier

    public init(
        yearBoundary: YearBoundaryRule,
        monthBoundary: MonthBoundaryRule,
        dayBoundary: DayBoundaryRule,
        ziHourPolicy: ZiHourPolicy,
        timeCorrection: TimeCorrectionPolicy,
        pillarTimeBasis: PillarTimeBasis,
        childLimitRule: ChildLimitRule,
        shenShaCatalog: ShenShaCatalogIdentifier
    ) {
        self.yearBoundary = yearBoundary
        self.monthBoundary = monthBoundary
        self.dayBoundary = dayBoundary
        self.ziHourPolicy = ziHourPolicy
        self.timeCorrection = timeCorrection
        self.pillarTimeBasis = pillarTimeBasis
        self.childLimitRule = childLimitRule
        self.shenShaCatalog = shenShaCatalog
    }

    /// The professional default rule set used when no rules are specified.
    public static let professionalDefault = BaziRuleSet(
        yearBoundary: .liChunExact,
        monthBoundary: .jieExact,
        dayBoundary: .civilMidnight,
        ziHourPolicy: .lateZiNextDay,
        timeCorrection: .standardClock,
        pillarTimeBasis: .astronomicalInstantForTerms,
        childLimitRule: .threeDaysPerYear,
        shenShaCatalog: .ziPingCommon
    )
}
