import Testing

/// Replays the committed golden fixtures through the calculator and asserts the
/// computed pillars match the source-backed expected values.
@Suite("Four pillars golden fixtures")
struct FourPillarsFixtureTests {
    @Test func basicCharts() throws {
        try FixtureSupport.evaluate("four-pillars-basic")
    }

    @Test func solarTermBoundaries() throws {
        try FixtureSupport.evaluate("solar-term-boundaries")
    }

    @Test func ziHourPolicies() throws {
        try FixtureSupport.evaluate("zi-hour-policies")
    }

    @Test func trueSolarTime() throws {
        try FixtureSupport.evaluate("true-solar-time")
    }

    /// Reference charts spanning decades, leap days, and the 子-hour boundary.
    @Test func referenceCharts() throws {
        try FixtureSupport.evaluate("four-pillars-reference")
    }
}
