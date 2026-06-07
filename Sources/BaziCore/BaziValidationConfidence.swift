/// How strongly a computed value is trusted.
public enum BaziValidationConfidence: String, CaseIterable, Codable, Hashable, Sendable {
    /// Deterministic and exact (pure arithmetic or high-precision astronomy).
    case canonical
    /// Cross-checked against an independent provider or golden fixture.
    case providerVerified
    /// Resolved only to date precision or via a documented approximation.
    case approximate
    /// Not yet validated against any reference.
    case unchecked
}
