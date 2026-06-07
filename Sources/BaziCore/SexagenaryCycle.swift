/// A stem–branch pair from the 60-term sexagenary cycle (干支); only matching-parity pairs are valid.
public struct SexagenaryCycle: Codable, Hashable, Sendable {
    /// The Heavenly Stem component.
    public let stem: HeavenlyStem
    /// The Earthly Branch component.
    public let branch: EarthlyBranch

    /// Creates a pair from a 60-cycle index (0 = 甲子, 59 = 癸亥); wraps cyclically.
    public init(index: Int) {
        let normalized = ModularArithmetic.positiveModulo(index, 60)
        self.stem = HeavenlyStem(normalizedIndex: normalized)
        self.branch = EarthlyBranch(normalizedIndex: normalized)
    }

    /// Creates a pair from explicit stem and branch; returns `nil` on mismatched parity.
    public init?(stem: HeavenlyStem, branch: EarthlyBranch) {
        guard stem.rawValue % 2 == branch.rawValue % 2 else { return nil }
        self.stem = stem
        self.branch = branch
    }

    /// Index in the 60-cycle (0 = 甲子, 59 = 癸亥).
    public var index: Int {
        ModularArithmetic.positiveModulo(6 * stem.rawValue - 5 * branch.rawValue, 60)
    }

    /// Chinese character pair (e.g. "甲子").
    public var chinese: String {
        "\(stem.chinese)\(branch.chinese)"
    }

    /// Returns the pair `steps` positions away; negative moves backward, wraps cyclically.
    public func advanced(by steps: Int) -> SexagenaryCycle {
        SexagenaryCycle(index: index + steps)
    }

    private enum CodingKeys: String, CodingKey {
        case stem
        case branch
    }
}
