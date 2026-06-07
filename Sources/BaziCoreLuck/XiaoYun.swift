import BaziCore

/// One year of the minor luck cycle (小运).
public struct XiaoYun: Codable, Hashable, Sendable {
    /// The counting age (虚岁, birth = 1).
    public let age: Int
    /// The Gregorian year.
    public let gregorianYear: Int
    /// The sexagenary pair for this year.
    public let pillar: SexagenaryCycle

    public init(age: Int, gregorianYear: Int, pillar: SexagenaryCycle) {
        self.age = age
        self.gregorianYear = gregorianYear
        self.pillar = pillar
    }

    /// Generates the minor luck cycle by stepping the hour pillar one position per counting year in the luck direction.
    public static func series(
        hourPillar: SexagenaryCycle,
        birthGregorianYear: Int,
        direction: LuckDirection,
        count: Int
    ) -> [XiaoYun] {
        let count = max(0, count)
        guard count > 0 else { return [] }

        var cycleIndex = hourPillar.index + direction.step
        var result: [XiaoYun] = []
        result.reserveCapacity(count)
        for offset in 0..<count {
            if cycleIndex >= 60 { cycleIndex -= 60 }
            if cycleIndex < 0 { cycleIndex += 60 }
            let age = offset + 1
            result.append(
                XiaoYun(
                    age: age,
                    gregorianYear: birthGregorianYear + age - 1,
                    pillar: SexagenaryCycle(index: cycleIndex)
                )
            )
            cycleIndex += direction.step
        }
        return result
    }
}
