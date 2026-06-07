/// Controlled vocabulary of audit notes attached to a computation.
public enum BaziComputationNote: String, CaseIterable, Codable, Hashable, Sendable {
    // Year boundary.
    case yearBoundaryLiChunExact
    case yearBoundaryLunarNewYear
    case birthBeforeLiChun
    case birthAtOrAfterLiChun

    // Month boundary.
    case monthBoundaryJieExact
    case monthAdvancedAtJieTerm

    // Day boundary and Zi hour.
    case dayBoundaryCivilMidnight
    case dayBoundaryZiHourStart
    case lateZiHourRolledToNextDay
    case lateZiHourKeptSameDay

    // Time correction.
    case timeUsesStandardClock
    case appliedLocalMeanSolarTime
    case appliedTrueSolarTime
    case removedDaylightSavingOffset
    case missingLocationUsedStandardClock

    // Term comparison basis and provider precision.
    case termBoundariesFromAstronomicalInstants
    case termBoundariesFromCorrectedLocalMoment
    case solarTermInstantHighPrecision
    case solarTermInstantDatePrecision

    // Luck cycle (大运 / 小运).
    case luckDirectionForward
    case luckDirectionBackward
    case childLimitFromNextJie
    case childLimitFromPreviousJie
}
