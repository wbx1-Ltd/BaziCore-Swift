import BaziCore

/// Where a ShenSha rule's formula comes from.
public enum ShenShaSource: String, CaseIterable, Codable, Hashable, Sendable {
    /// A widely-cited classical rule.
    case ziPingClassic
}

/// A single ShenSha (神煞) hit: which symbolic star landed on which pillar.
public struct ShenSha: Hashable, Sendable, Codable {
    /// Stable rule identifier.
    public let identifier: String
    /// Chinese display name, e.g. "天乙贵人".
    public let displayName: String
    /// The pillar the ShenSha landed on.
    public let pillar: PillarKind
    /// The branch that triggered the hit.
    public let branch: EarthlyBranch
    /// Where the rule comes from.
    public let source: ShenShaSource

    public init(
        identifier: String,
        displayName: String,
        pillar: PillarKind,
        branch: EarthlyBranch,
        source: ShenShaSource
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.pillar = pillar
        self.branch = branch
        self.source = source
    }
}
