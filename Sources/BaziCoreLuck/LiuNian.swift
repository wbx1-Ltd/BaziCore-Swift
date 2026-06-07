import BaziCore
import BaziCoreTables

/// One fleeting year (流年).
public struct LiuNian: Codable, Hashable, Sendable {
    /// The Gregorian year.
    public let gregorianYear: Int
    /// The counting age (虚岁, birth = 1).
    public let age: Int
    /// The sexagenary pair of the year.
    public let pillar: SexagenaryCycle
    /// The ten god of the year stem relative to the day master.
    public let stemTenGod: TenGod

    public init(gregorianYear: Int, age: Int, pillar: SexagenaryCycle, stemTenGod: TenGod) {
        self.gregorianYear = gregorianYear
        self.age = age
        self.pillar = pillar
        self.stemTenGod = stemTenGod
    }
}

/// Generates the fleeting-year (流年) sequence.
public enum LiuNianEngine {
    /// Generates `count` fleeting years from `fromYear`, with counting age and ten god relative to the day master.
    public static func series(
        birthGregorianYear: Int,
        dayMaster: HeavenlyStem,
        fromYear: Int,
        count: Int
    ) -> [LiuNian] {
        let count = max(0, count)
        guard count > 0 else { return [] }

        var result: [LiuNian] = []
        result.reserveCapacity(count)
        var cycleIndex = ((fromYear - 4) % 60 + 60) % 60
        for offset in 0..<count {
            let year = fromYear + offset
            let pillar = SexagenaryCycle(index: cycleIndex)
            result.append(
                LiuNian(
                    gregorianYear: year,
                    age: year - birthGregorianYear + 1,
                    pillar: pillar,
                    stemTenGod: TenGodEngine.tenGod(of: pillar.stem, dayMaster: dayMaster)
                )
            )
            cycleIndex += 1
            if cycleIndex == 60 { cycleIndex = 0 }
        }
        return result
    }
}
