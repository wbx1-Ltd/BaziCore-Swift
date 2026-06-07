/// Polarity (阴阳).
public enum YinYang: String, CaseIterable, Codable, Hashable, Sendable {
    case yang
    case yin

    /// Chinese character (阳 / 阴).
    public var chinese: String {
        switch self {
        case .yang: "阳"
        case .yin: "阴"
        }
    }
}
