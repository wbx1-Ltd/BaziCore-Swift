import BaziCore

/// A named, versioned collection of ShenSha rules.
public struct ShenShaCatalog: Sendable {
    public let identifier: ShenShaCatalogIdentifier
    public let rules: [any ShenShaRule]

    public init(identifier: ShenShaCatalogIdentifier, rules: [any ShenShaRule]) {
        self.identifier = identifier
        self.rules = rules
    }

    /// Evaluates every rule in the catalog against a chart.
    public func evaluate(chart: BaziChart) -> [ShenSha] {
        var hits: [ShenSha] = []
        hits.reserveCapacity(rules.count)
        for rule in rules {
            hits.append(contentsOf: rule.evaluate(chart: chart))
        }
        return hits
    }

    /// The common catalog of widely-cited ShenSha.
    public static let ziPingCommon = ShenShaCatalog(
        identifier: .ziPingCommon,
        rules: CommonShenShaRule.allCases
    )

    /// Returns the catalog for an identifier.
    public static func catalog(for identifier: ShenShaCatalogIdentifier) -> ShenShaCatalog {
        switch identifier {
        case .ziPingCommon: .ziPingCommon
        }
    }
}
