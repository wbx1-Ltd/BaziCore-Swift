import BaziCore
import BaziCoreAstronomy
import BaziCoreTesting
import Foundation
import Testing

/// Shared loading and evaluation helpers for the golden-fixture tests.
enum FixtureSupport {
    static let calculatorProvider = AstronomicalSolarTermProvider()
    static let corrector = TrueSolarTimeEngine()

    static func load(_ name: String) throws -> [GoldenFixture] {
        let url = try #require(
            Bundle.module.url(forResource: name, withExtension: "json"),
            "missing fixture resource \(name).json"
        )
        return try FixtureLoader.load(from: url)
    }

    /// Computes a chart for a fixture using the high-precision providers.
    static func chart(for fixture: GoldenFixture) throws -> BaziChart {
        let calculator = BaziCalculator(
            ruleSet: fixture.baziRuleSet(),
            solarTermProvider: calculatorProvider,
            timeCorrectionProvider: corrector
        )
        return try calculator.chart(for: fixture.birthInput())
    }

    /// Evaluates every fixture in a file and reports any mismatches.
    static func evaluate(_ name: String) throws {
        for fixture in try load(name) {
            let chart = try chart(for: fixture)
            let comparison = FixtureAssertion.compare(
                id: fixture.id, expected: fixture.expected, actual: chart.fourPillars
            )
            #expect(comparison.passed, "\(fixture.id): \(comparison.mismatches.joined(separator: "; "))")
        }
    }
}
