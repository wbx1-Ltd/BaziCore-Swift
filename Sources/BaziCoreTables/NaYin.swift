/// A NaYin (纳音) value: its traditional name and the element it belongs to.
public struct NaYin: Hashable, Sendable, Codable {
    /// Chinese name, e.g. "海中金".
    public let chinese: String
    /// The five-element phase of this NaYin.
    public let element: Element

    public init(chinese: String, element: Element) {
        self.chinese = chinese
        self.element = element
    }
}
