import BaziCore

/// The void branches (空亡 / 旬空) for a pillar, derived from its decade (旬).
public struct VoidBranch: Hashable, Sendable, Codable {
    /// The decade index (0 = 甲子旬 … 5 = 甲寅旬).
    public let decadeIndex: Int
    /// The two void branches.
    public let branches: [EarthlyBranch]

    public init(decadeIndex: Int, branches: [EarthlyBranch]) {
        self.decadeIndex = decadeIndex
        self.branches = branches
    }

    /// The void branches for a pillar's sexagenary pair, conventionally the day pillar.
    public static func forPillar(_ cycle: SexagenaryCycle) -> VoidBranch {
        let decade = cycle.index / 10
        let startBranch = decade * 10
        let branches = [
            EarthlyBranch(normalizedIndex: startBranch + 10),
            EarthlyBranch(normalizedIndex: startBranch + 11)
        ]
        return VoidBranch(decadeIndex: decade, branches: branches)
    }

    /// Whether the given branch is void in this decade.
    public func contains(_ branch: EarthlyBranch) -> Bool {
        branches.contains(branch)
    }
}
