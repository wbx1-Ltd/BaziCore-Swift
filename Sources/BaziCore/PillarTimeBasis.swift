/// How the year and month boundaries are compared against the birth moment.
public enum PillarTimeBasis: String, CaseIterable, Codable, Hashable, Sendable {
    /// Compare the birth instant against absolute solar-term instants. Professional default.
    case astronomicalInstantForTerms
    /// Correct the birth moment first, then compare every pillar against it. Compatibility mode.
    case correctedLocalMomentForAllPillars
}
