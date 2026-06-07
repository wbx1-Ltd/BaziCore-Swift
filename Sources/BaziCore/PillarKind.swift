/// Which of the four pillars (四柱) a value represents.
public enum PillarKind: String, CaseIterable, Codable, Hashable, Sendable {
    case year
    case month
    case day
    case hour

    /// Chinese label (年柱 / 月柱 / 日柱 / 时柱).
    public var chineseName: String {
        switch self {
        case .year: "年柱"
        case .month: "月柱"
        case .day: "日柱"
        case .hour: "时柱"
        }
    }
}
