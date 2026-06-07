import BaziCore

/// Generates the luck periods (大运) by stepping the month pillar in the luck direction, each spanning ten years.
public enum DaYunEngine {
    /// Generates `count` luck periods starting at the child limit (起运).
    public static func compute(
        monthPillar: SexagenaryCycle,
        birthGregorianYear: Int,
        childLimit: ChildLimit,
        direction: LuckDirection,
        count: Int = 12
    ) -> [DaYun] {
        let count = max(0, count)
        guard count > 0 else { return [] }

        let firstStartYear = childLimit.startGregorianYear
        let firstStartAge = firstStartYear - birthGregorianYear + 1
        var cycleIndex = monthPillar.index + direction.step
        var result: [DaYun] = []
        result.reserveCapacity(count)
        for index in 0..<count {
            if cycleIndex >= 60 { cycleIndex -= 60 }
            if cycleIndex < 0 { cycleIndex += 60 }
            let startYear = firstStartYear + index * 10
            result.append(
                DaYun(
                    index: index,
                    pillar: SexagenaryCycle(index: cycleIndex),
                    startAge: firstStartAge + index * 10,
                    startGregorianYear: startYear,
                    endGregorianYear: startYear + 9
                )
            )
            cycleIndex += direction.step
        }
        return result
    }
}
