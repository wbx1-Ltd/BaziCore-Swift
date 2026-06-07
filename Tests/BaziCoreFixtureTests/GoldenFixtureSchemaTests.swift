import BaziCoreTesting
import Foundation
import Testing

@Suite("Golden fixture schema")
struct GoldenFixtureSchemaTests {
    private let files = [
        "four-pillars-basic",
        "solar-term-boundaries",
        "zi-hour-policies",
        "true-solar-time",
        "four-pillars-reference"
    ]

    @Test func everyFixtureFileLoads() throws {
        for file in files {
            let fixtures = try FixtureSupport.load(file)
            #expect(!fixtures.isEmpty, "\(file) is empty")
        }
    }

    @Test func fixturesHaveStableIdentitiesAndExpectedPillars() throws {
        var seen = Set<String>()
        for file in files {
            for fixture in try FixtureSupport.load(file) {
                #expect(seen.insert(fixture.id).inserted, "duplicate fixture id \(fixture.id)")
                #expect(!fixture.expected.year.isEmpty)
                #expect(!fixture.expected.month.isEmpty)
                #expect(!fixture.expected.day.isEmpty)
                #expect(!fixture.expected.hour.isEmpty)
                #expect(!fixture.sources.isEmpty, "\(fixture.id) has no source")
            }
        }
    }

    @Test func birthInputAndRuleSetBuild() throws {
        for file in files {
            for fixture in try FixtureSupport.load(file) {
                let input = try fixture.birthInput()
                #expect(input.moment.year == fixture.input.year)
                _ = fixture.baziRuleSet()
            }
        }
    }
}
