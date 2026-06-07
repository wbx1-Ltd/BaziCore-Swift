/// Provenance for a validation source backing a fixture's expected values.
public struct SourceMetadata: Codable, Equatable, Hashable, Sendable {
    /// Stable identifier.
    public let identifier: String
    /// Human-readable name.
    public let name: String
    /// What kind of source this is.
    public let kind: SourceKind
    /// Optional reference URL.
    public let reference: String?

    public init(identifier: String, name: String, kind: SourceKind, reference: String? = nil) {
        self.identifier = identifier
        self.name = name
        self.kind = kind
        self.reference = reference
    }
}

/// The category of a validation source.
public enum SourceKind: String, CaseIterable, Codable, Hashable, Sendable {
    /// An official authority.
    case official
    /// An open-source library used only for local, development-time cross-checks.
    case library
    /// A value defined by the BaZi rule itself.
    case rule
}

extension SourceMetadata {
    /// Our own engines (astronomy plus deterministic rules).
    public static let baziCore = SourceMetadata(
        identifier: "bazicore",
        name: "BaziCore engines",
        kind: .rule,
        reference: nil
    )
    public static let baziRule = SourceMetadata(
        identifier: "bazi-rule",
        name: "BaZi rule definition",
        kind: .rule,
        reference: nil
    )
}
