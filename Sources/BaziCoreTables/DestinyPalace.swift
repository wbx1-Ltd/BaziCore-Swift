import BaziCore

/// The three derived palaces of a chart: 胎元, 命宫, and 身宫.
public struct DestinyPalaces: Hashable, Sendable, Codable {
    /// 胎元 — the fetal origin, from the month pillar.
    public let fetalOrigin: SexagenaryCycle
    /// 命宫 — the life palace, from the month and hour branches.
    public let lifePalace: SexagenaryCycle
    /// 身宫 — the body palace, from the month and hour branches.
    public let bodyPalace: SexagenaryCycle

    public init(fetalOrigin: SexagenaryCycle, lifePalace: SexagenaryCycle, bodyPalace: SexagenaryCycle) {
        self.fetalOrigin = fetalOrigin
        self.lifePalace = lifePalace
        self.bodyPalace = bodyPalace
    }

    /// Computes the three palaces from the four pillars.
    public static func compute(fourPillars: FourPillars) -> DestinyPalaces {
        let yearStem = fourPillars.year.stem
        let monthStem = fourPillars.month.stem
        let monthBranch = fourPillars.month.branch
        let hourBranch = fourPillars.hour.branch

        // 胎元: month stem advances one, month branch advances three.
        let fetal = cycle(
            stemIndex: (monthStem.rawValue + 1) % 10,
            branchIndex: (monthBranch.rawValue + 3) % 12
        )

        // 命宫 / 身宫 branches, with stems by the Five Tiger rule from the year stem.
        let lifeBranch = (5 - monthBranch.rawValue - hourBranch.rawValue) % 12
        let bodyBranch = (1 + monthBranch.rawValue + hourBranch.rawValue) % 12
        let life = palace(yearStem: yearStem, branchIndex: lifeBranch)
        let body = palace(yearStem: yearStem, branchIndex: bodyBranch)

        return DestinyPalaces(fetalOrigin: fetal, lifePalace: life, bodyPalace: body)
    }

    /// Builds a palace pillar: branch normalized, stem by Five Tiger from the year.
    private static func palace(yearStem: HeavenlyStem, branchIndex: Int) -> SexagenaryCycle {
        let branch = EarthlyBranch(normalizedIndex: branchIndex)
        let monthNumber = ((branch.rawValue + 10) % 12) + 1 // 寅 = 1 … 丑 = 12
        let stemIndex = ((yearStem.rawValue % 5) * 2 + 2 + monthNumber - 1) % 10
        return cycle(stemIndex: stemIndex, branchIndex: branch.rawValue)
    }

    private static func cycle(stemIndex: Int, branchIndex: Int) -> SexagenaryCycle {
        SexagenaryCycle(index: ((6 * stemIndex - 5 * branchIndex) % 60 + 60) % 60)
    }
}
