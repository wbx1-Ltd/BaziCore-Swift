import Foundation

/// Computes the month pillar (月柱) by 节 solar terms, deriving the stem from the year stem.
public enum MonthPillarEngine {
    public struct Result: Sendable {
        public let pillar: Pillar
        /// The BaZi month number (1 = 寅月 … 12 = 丑月).
        public let monthNumber: Int
        public let notes: [BaziComputationNote]
        public let details: [BaziTraceDetail]
    }

    /// Computes the month pillar for a birth instant.
    public static func compute(
        instant: Date,
        gregorianYear: Int,
        yearStem: HeavenlyStem,
        gregorianMonth: Int? = nil,
        provider: any SolarTermInstantProvider
    ) throws(BaziError) -> Result {
        guard let governing = try governingJie(
            instant: instant,
            gregorianYear: gregorianYear,
            gregorianMonth: gregorianMonth,
            provider: provider
        ),
            let monthNumber = governing.term.baziMonthNumber,
            let branch = governing.term.baziMonthBranch
        else {
            throw .solarTermUnavailable(term: .liChun, year: gregorianYear)
        }

        // Month stem derived from the year stem.
        let stemIndex = ((yearStem.rawValue % 5) * 2 + 2 + monthNumber - 1) % 10
        let cycleIndex = ModularArithmetic.positiveModulo(6 * stemIndex - 5 * branch.rawValue, 60)
        let cycle = SexagenaryCycle(index: cycleIndex)

        let notes: [BaziComputationNote] = [.monthBoundaryJieExact, .monthAdvancedAtJieTerm]
        let details: [BaziTraceDetail] = [
            BaziTraceDetail(key: .monthBoundaryTerm, value: governing.term.chineseName),
            BaziTraceDetail(
                key: .monthBoundaryInstant,
                value: TraceFormat.iso(governing.date),
                date: governing.date
            ),
            BaziTraceDetail(key: .effectiveMonthNumber, value: String(monthNumber))
        ]

        return Result(
            pillar: Pillar(kind: .month, cycle: cycle),
            monthNumber: monthNumber,
            notes: notes,
            details: details
        )
    }

    /// The latest *Jie* term instant at or before the birth instant.
    private static func governingJie(
        instant: Date,
        gregorianYear: Int,
        gregorianMonth: Int?,
        provider: any SolarTermInstantProvider
    ) throws(BaziError) -> SolarTermInstant? {
        var governing: SolarTermInstant?
        for (term, year) in requiredJieRequests(for: gregorianYear, gregorianMonth: gregorianMonth) {
            guard let termInstant = provider.solarTermInstant(term, gregorianYear: year) else {
                throw .solarTermUnavailable(term: term, year: year)
            }
            if termInstant.date <= instant, governing == nil || termInstant.date > governing!.date {
                governing = termInstant
            }
        }
        return governing
    }

    private static func requiredJieRequests(
        for gregorianYear: Int,
        gregorianMonth: Int?
    ) -> [(SolarTermKind, Int)] {
        if let gregorianMonth, let adjacent = adjacentJieRequests(for: gregorianYear, month: gregorianMonth) {
            return adjacent
        }

        return [
            (.daXue, gregorianYear - 1),
            (.xiaoHan, gregorianYear),
            (.liChun, gregorianYear),
            (.jingZhe, gregorianYear),
            (.qingMing, gregorianYear),
            (.liXia, gregorianYear),
            (.mangZhong, gregorianYear),
            (.xiaoShu, gregorianYear),
            (.liQiu, gregorianYear),
            (.baiLu, gregorianYear),
            (.hanLu, gregorianYear),
            (.liDong, gregorianYear),
            (.daXue, gregorianYear)
        ]
    }

    private static func adjacentJieRequests(
        for gregorianYear: Int,
        month: Int
    ) -> [(SolarTermKind, Int)]? {
        switch month {
        case 1: [(.daXue, gregorianYear - 1), (.xiaoHan, gregorianYear)]
        case 2: [(.xiaoHan, gregorianYear), (.liChun, gregorianYear)]
        case 3: [(.liChun, gregorianYear), (.jingZhe, gregorianYear)]
        case 4: [(.jingZhe, gregorianYear), (.qingMing, gregorianYear)]
        case 5: [(.qingMing, gregorianYear), (.liXia, gregorianYear)]
        case 6: [(.liXia, gregorianYear), (.mangZhong, gregorianYear)]
        case 7: [(.mangZhong, gregorianYear), (.xiaoShu, gregorianYear)]
        case 8: [(.xiaoShu, gregorianYear), (.liQiu, gregorianYear)]
        case 9: [(.liQiu, gregorianYear), (.baiLu, gregorianYear)]
        case 10: [(.baiLu, gregorianYear), (.hanLu, gregorianYear)]
        case 11: [(.hanLu, gregorianYear), (.liDong, gregorianYear)]
        case 12: [(.liDong, gregorianYear), (.daXue, gregorianYear)]
        default: nil
        }
    }
}
