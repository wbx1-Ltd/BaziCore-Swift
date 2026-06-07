/// A summary of how two providers' outputs agree across a set of cases.
public struct ProviderParityReport: Equatable, Sendable {
    /// One field-level disagreement between two providers.
    public struct Disagreement: Equatable, Sendable {
        public let id: String
        public let field: String
        public let lhs: String
        public let rhs: String

        public init(id: String, field: String, lhs: String, rhs: String) {
            self.id = id
            self.field = field
            self.lhs = lhs
            self.rhs = rhs
        }
    }

    public let total: Int
    public let agreements: Int
    public let disagreements: [Disagreement]

    public init(total: Int, agreements: Int, disagreements: [Disagreement]) {
        self.total = total
        self.agreements = agreements
        self.disagreements = disagreements
    }

    /// Fraction of cases that agreed (1.0 when there were no cases).
    public var agreementRate: Double {
        total == 0 ? 1.0 : Double(agreements) / Double(total)
    }

    /// Builds a report from labelled `(lhs, rhs)` value pairs.
    public static func build(cases: [(id: String, field: String, lhs: String, rhs: String)]) -> ProviderParityReport {
        var agreements = 0
        var disagreements: [Disagreement] = []
        for entry in cases {
            if entry.lhs == entry.rhs {
                agreements += 1
            } else {
                disagreements.append(
                    Disagreement(id: entry.id, field: entry.field, lhs: entry.lhs, rhs: entry.rhs)
                )
            }
        }
        return ProviderParityReport(total: cases.count, agreements: agreements, disagreements: disagreements)
    }
}
