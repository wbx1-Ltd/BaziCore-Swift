import Foundation

/// Computes the four pillars of a chart from a birth input and rule set.
public struct BaziCalculator: Sendable {
    public var ruleSet: BaziRuleSet
    public var solarTermProvider: any SolarTermInstantProvider
    public var timeCorrectionProvider: (any SolarTimeCorrectionProvider)?

    public init(
        ruleSet: BaziRuleSet = .professionalDefault,
        solarTermProvider: any SolarTermInstantProvider,
        timeCorrectionProvider: (any SolarTimeCorrectionProvider)? = nil
    ) {
        self.ruleSet = ruleSet
        self.solarTermProvider = solarTermProvider
        self.timeCorrectionProvider = timeCorrectionProvider
    }

    /// Computes the four pillars chart for a birth input.
    public func chart(for input: BirthInput) throws(BaziError) -> BaziChart {
        let effective = try ChartEngine.resolveEffectiveTime(
            input: input, ruleSet: ruleSet, corrector: timeCorrectionProvider
        )

        // term boundaries compare an instant; corrected basis shifts it so all pillars share one clock.
        var basisNotes: [BaziComputationNote] = []
        let comparisonInstant: Date
        switch ruleSet.pillarTimeBasis {
        case .astronomicalInstantForTerms:
            comparisonInstant = input.moment.instant
            basisNotes.append(.termBoundariesFromAstronomicalInstants)
        case .correctedLocalMomentForAllPillars:
            comparisonInstant = input.moment.instant
                .addingTimeInterval(effective.correction?.totalCorrectionSeconds ?? 0)
            basisNotes.append(.termBoundariesFromCorrectedLocalMoment)
        }

        let year = try YearPillarEngine.compute(
            instant: comparisonInstant, gregorianYear: input.moment.year,
            rule: ruleSet.yearBoundary, provider: solarTermProvider
        )
        let month = try MonthPillarEngine.compute(
            instant: comparisonInstant, gregorianYear: input.moment.year,
            yearStem: year.pillar.stem, gregorianMonth: input.moment.month, provider: solarTermProvider
        )
        let day = DayPillarEngine.compute(
            year: effective.year, month: effective.month, day: effective.day, hour: effective.hour,
            dayBoundary: ruleSet.dayBoundary, ziHourPolicy: ruleSet.ziHourPolicy
        )
        let hour = HourPillarEngine.compute(effectiveHour: effective.hour, dayStem: day.pillar.stem)

        let fourPillars = FourPillars(
            year: year.pillar, month: month.pillar, day: day.pillar, hour: hour.pillar
        )
        let trace = buildTrace(
            effective: effective, basisNotes: basisNotes,
            year: year, month: month, day: day, hour: hour
        )

        return BaziChart(input: input, ruleSet: ruleSet, fourPillars: fourPillars, trace: trace)
    }

    private func buildTrace(
        effective: ChartEngine.EffectiveTime,
        basisNotes: [BaziComputationNote],
        year: YearPillarEngine.Result,
        month: MonthPillarEngine.Result,
        day: DayPillarEngine.Result,
        hour: HourPillarEngine.Result
    ) -> ComputationTrace {
        let correctionApplied = effective.correction != nil && ruleSet.timeCorrection != .standardClock
        let baseKind = solarTermProvider.providerKind
        let provider: BaziProviderKind = correctionApplied ? .hybrid : baseKind
        let confidence: BaziValidationConfidence = baseKind == .astronomy ? .canonical : .approximate

        var notes: [BaziComputationNote] = []
        notes.reserveCapacity(
            effective.notes.count + basisNotes.count + 1
                + year.notes.count + month.notes.count + day.notes.count + hour.notes.count
        )
        notes.append(contentsOf: effective.notes)
        notes.append(contentsOf: basisNotes)
        notes.append(baseKind == .astronomy ? .solarTermInstantHighPrecision : .solarTermInstantDatePrecision)
        notes.append(contentsOf: year.notes)
        notes.append(contentsOf: month.notes)
        notes.append(contentsOf: day.notes)
        notes.append(contentsOf: hour.notes)

        var details: [BaziTraceDetail] = []
        details.reserveCapacity(
            effective.details.count + year.details.count + month.details.count + day.details.count + hour.details.count
        )
        details.append(contentsOf: effective.details)
        details.append(contentsOf: year.details)
        details.append(contentsOf: month.details)
        details.append(contentsOf: day.details)
        details.append(contentsOf: hour.details)

        return ComputationTrace(
            provider: provider,
            confidence: confidence,
            notes: notes,
            details: details
        )
    }
}
