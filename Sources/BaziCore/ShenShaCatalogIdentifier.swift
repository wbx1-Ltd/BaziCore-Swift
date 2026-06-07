/// Selects which ShenSha (神煞) rule catalog a chart is evaluated against; a stable versioned key.
public enum ShenShaCatalogIdentifier: String, CaseIterable, Codable, Hashable, Sendable {
    /// A common 子平 (Zi Ping) catalog of widely-cited ShenSha. Default.
    case ziPingCommon
}
