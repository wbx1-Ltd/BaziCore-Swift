import BaziCore

/// The role a hidden stem (藏干) plays within its branch.
public enum HiddenStemRole: String, CaseIterable, Codable, Hashable, Sendable {
    /// 本气 — the dominant qi, listed first.
    case primaryQi
    /// 中气 — the secondary qi.
    case middleQi
    /// 余气 — the residual qi.
    case residualQi
}

/// One stem concealed within a branch (藏干), with a relative strength weight.
public struct HiddenStem: Hashable, Sendable, Codable {
    public let stem: HeavenlyStem
    public let role: HiddenStemRole
    /// Relative strength on a 0–100 scale.
    public let weight: Int

    public init(stem: HeavenlyStem, role: HiddenStemRole, weight: Int) {
        self.stem = stem
        self.role = role
        self.weight = weight
    }
}
