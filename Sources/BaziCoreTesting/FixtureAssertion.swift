import BaziCore

/// The outcome of comparing a computed chart to a fixture's expected pillars.
public struct FixtureComparison: Equatable, Sendable {
    public let id: String
    public let mismatches: [String]

    public var passed: Bool { mismatches.isEmpty }

    public init(id: String, mismatches: [String]) {
        self.id = id
        self.mismatches = mismatches
    }
}

/// Compares computed pillars against fixture expectations.
public enum FixtureAssertion {
    /// Compares the four pillars against a fixture's expected GanZhi strings.
    public static func compare(
        id: String,
        expected: FixturePillars,
        actual: FourPillars
    ) -> FixtureComparison {
        var mismatches: [String] = []
        check("year", expected.year, actual.year.chinese, &mismatches)
        check("month", expected.month, actual.month.chinese, &mismatches)
        check("day", expected.day, actual.day.chinese, &mismatches)
        check("hour", expected.hour, actual.hour.chinese, &mismatches)
        return FixtureComparison(id: id, mismatches: mismatches)
    }

    private static func check(
        _ field: String, _ expected: String, _ actual: String, _ mismatches: inout [String]
    ) {
        if expected != actual {
            mismatches.append("\(field): expected \(expected), got \(actual)")
        }
    }
}
