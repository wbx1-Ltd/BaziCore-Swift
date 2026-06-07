import Foundation

/// Computes the year pillar (年柱), changing at the exact 立春 instant by default.
public enum YearPillarEngine {
    public struct Result: Sendable {
        public let pillar: Pillar
        /// The sexagenary year number whose stem/branch the pillar uses.
        public let effectiveYear: Int
        public let notes: [BaziComputationNote]
        public let details: [BaziTraceDetail]
    }

    /// Computes the year pillar for a birth instant.
    public static func compute(
        instant: Date,
        gregorianYear: Int,
        rule: YearBoundaryRule,
        provider: any SolarTermInstantProvider
    ) throws(BaziError) -> Result {
        switch rule {
        case .liChunExact:
            try computeLiChun(instant: instant, gregorianYear: gregorianYear, provider: provider)
        case .lunarNewYear:
            throw .unsupportedInputCalendar(
                detail: "lunarNewYear year boundary requires a lunar-calendar provider (BaziCoreLunarCoreAdapter)"
            )
        }
    }

    private static func computeLiChun(
        instant: Date,
        gregorianYear: Int,
        provider: any SolarTermInstantProvider
    ) throws(BaziError) -> Result {
        guard let liChun = provider.solarTermInstant(.liChun, gregorianYear: gregorianYear) else {
            throw .solarTermUnavailable(term: .liChun, year: gregorianYear)
        }

        let beforeLiChun = instant < liChun.date
        let effectiveYear = beforeLiChun ? gregorianYear - 1 : gregorianYear
        let cycle = SexagenaryCycle(index: ModularArithmetic.positiveModulo(effectiveYear - 4, 60))

        let notes: [BaziComputationNote] = [
            .yearBoundaryLiChunExact,
            beforeLiChun ? .birthBeforeLiChun : .birthAtOrAfterLiChun
        ]
        let details: [BaziTraceDetail] = [
            BaziTraceDetail(key: .liChunInstant, value: TraceFormat.iso(liChun.date), date: liChun.date),
            BaziTraceDetail(key: .comparedYearNumber, value: String(effectiveYear)),
            BaziTraceDetail(key: .effectiveYearStem, value: cycle.stem.chinese)
        ]

        return Result(
            pillar: Pillar(kind: .year, cycle: cycle),
            effectiveYear: effectiveYear,
            notes: notes,
            details: details
        )
    }
}
