/// How the civil clock is corrected before resolving day and hour pillars; off by default.
public enum TimeCorrectionPolicy: String, CaseIterable, Codable, Hashable, Sendable {
    /// Use the civil clock time as given. No correction.
    case standardClock
    /// Apply only the longitude offset from the time-zone meridian, yielding local mean solar time.
    case localMeanSolarTime
    /// Apply the longitude offset plus the equation of time, yielding apparent (true) solar time.
    case trueSolarTime
}
