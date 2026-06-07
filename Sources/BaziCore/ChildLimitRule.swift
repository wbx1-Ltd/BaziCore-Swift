/// How the luck-cycle starting age (起运) is derived from distance to the neighbouring *Jie* term.
public enum ChildLimitRule: String, CaseIterable, Codable, Hashable, Sendable {
    /// Classical rule: three days of distance equal one year of age (三天折一岁).
    case threeDaysPerYear
}
