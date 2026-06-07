/// The five elements / phases (五行).
public enum Element: String, CaseIterable, Codable, Hashable, Sendable {
    case wood
    case fire
    case earth
    case metal
    case water

    /// Chinese character (木 火 土 金 水).
    public var chinese: String {
        switch self {
        case .wood: "木"
        case .fire: "火"
        case .earth: "土"
        case .metal: "金"
        case .water: "水"
        }
    }

    /// The element this one generates (相生): 木→火→土→金→水→木.
    public func generates() -> Element {
        switch self {
        case .wood: .fire
        case .fire: .earth
        case .earth: .metal
        case .metal: .water
        case .water: .wood
        }
    }

    /// The element this one controls (相克): 木克土, 土克水, 水克火, 火克金, 金克木.
    public func controls() -> Element {
        switch self {
        case .wood: .earth
        case .fire: .metal
        case .earth: .water
        case .metal: .wood
        case .water: .fire
        }
    }

    /// Whether this element generates `other` (我生 relative to this element).
    public func generates(_ other: Element) -> Bool {
        generates() == other
    }

    /// Whether this element controls `other` (我克 relative to this element).
    public func controls(_ other: Element) -> Bool {
        controls() == other
    }
}
