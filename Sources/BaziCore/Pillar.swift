/// A single pillar (柱): a stem–branch pair tagged with its position.
public struct Pillar: Codable, Hashable, Sendable {
    /// Which of the four positions this pillar occupies.
    public let kind: PillarKind
    /// The underlying sexagenary stem–branch pair.
    public let cycle: SexagenaryCycle

    public init(kind: PillarKind, cycle: SexagenaryCycle) {
        self.kind = kind
        self.cycle = cycle
    }

    /// The Heavenly Stem component.
    public var stem: HeavenlyStem { cycle.stem }
    /// The Earthly Branch component.
    public var branch: EarthlyBranch { cycle.branch }
    /// Index in the 60-cycle (0 = 甲子, 59 = 癸亥).
    public var ganZhiIndex: Int { cycle.index }
    /// Chinese character pair (e.g. "甲子").
    public var chinese: String { cycle.chinese }
}
