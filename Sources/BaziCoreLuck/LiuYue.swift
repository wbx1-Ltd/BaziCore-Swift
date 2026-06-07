import BaziCore
import Foundation

/// One fleeting month (流月) within a fleeting year.
public struct LiuYue: Codable, Hashable, Sendable {
    /// The 流年 (sexagenary year) this month belongs to.
    public let gregorianYear: Int
    /// The BaZi month number (1 = 寅月 … 12 = 丑月).
    public let monthNumber: Int
    /// The sexagenary pair of the month.
    public let pillar: SexagenaryCycle
    /// The 节 term that opens this month.
    public let startTerm: SolarTermKind
    /// The instant the month begins.
    public let startInstant: Date
    /// The instant the month ends (the next 节 term).
    public let endInstant: Date

    public init(
        gregorianYear: Int,
        monthNumber: Int,
        pillar: SexagenaryCycle,
        startTerm: SolarTermKind,
        startInstant: Date,
        endInstant: Date
    ) {
        self.gregorianYear = gregorianYear
        self.monthNumber = monthNumber
        self.pillar = pillar
        self.startTerm = startTerm
        self.startInstant = startInstant
        self.endInstant = endInstant
    }
}

/// Generates the twelve fleeting months (流月) of a fleeting year.
public enum LiuYueEngine {
    /// Month number (1 = 寅) to its opening 节 term.
    private static let openingTerms: [SolarTermKind] = [
        .liChun, .jingZhe, .qingMing, .liXia, .mangZhong, .xiaoShu,
        .liQiu, .baiLu, .hanLu, .liDong, .daXue, .xiaoHan
    ]

    /// Generates the twelve months of the 流年 beginning at 立春 of `gregorianYear`.
    public static func series(
        gregorianYear year: Int,
        provider: any SolarTermInstantProvider
    ) throws(BaziError) -> [LiuYue] {
        let yearStem = SexagenaryCycle(index: ((year - 4) % 60 + 60) % 60).stem
        let boundaries = try monthBoundaries(gregorianYear: year, provider: provider)

        var result: [LiuYue] = []
        result.reserveCapacity(12)
        for index in 0..<12 {
            let monthNumber = index + 1
            let start = boundaries[index]
            let end = boundaries[index + 1].instant.date

            let stemIndex = ((yearStem.rawValue % 5) * 2 + 2 + monthNumber - 1) % 10
            let branchIndex = (monthNumber + 1) % 12
            let cycleIndex = ((6 * stemIndex - 5 * branchIndex) % 60 + 60) % 60

            result.append(
                LiuYue(
                    gregorianYear: year,
                    monthNumber: monthNumber,
                    pillar: SexagenaryCycle(index: cycleIndex),
                    startTerm: start.term,
                    startInstant: start.instant.date,
                    endInstant: end
                )
            )
        }
        return result
    }

    private struct Boundary {
        let term: SolarTermKind
        let instant: SolarTermInstant
    }

    private static func monthBoundaries(
        gregorianYear year: Int,
        provider: any SolarTermInstantProvider
    ) throws(BaziError) -> [Boundary] {
        var boundaries: [Boundary] = []
        boundaries.reserveCapacity(13)
        for index in 0..<openingTerms.count {
            let monthNumber = index + 1
            let term = openingTerms[index]
            // 丑月 (month 12, 小寒) opens in January of the following calendar year.
            let termYear = monthNumber == 12 ? year + 1 : year
            guard let instant = provider.solarTermInstant(term, gregorianYear: termYear) else {
                throw .solarTermUnavailable(term: term, year: termYear)
            }
            boundaries.append(Boundary(term: term, instant: instant))
        }
        guard let nextLiChun = provider.solarTermInstant(.liChun, gregorianYear: year + 1) else {
            throw .solarTermUnavailable(term: .liChun, year: year + 1)
        }
        boundaries.append(Boundary(term: .liChun, instant: nextLiChun))
        return boundaries
    }
}
