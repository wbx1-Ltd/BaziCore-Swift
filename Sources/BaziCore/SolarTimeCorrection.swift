/// The effective local clock reading after a solar-time correction, with its breakdown.
public struct SolarTimeCorrection: Codable, Hashable, Sendable {
    /// The policy that produced this correction.
    public let policy: TimeCorrectionPolicy
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let second: Int
    /// Longitude offset from the time-zone's standard meridian, in seconds.
    public let longitudeCorrectionSeconds: Double
    /// Equation-of-time contribution, in seconds (zero for local mean solar time).
    public let equationOfTimeSeconds: Double
    /// Daylight-saving offset removed before applying the correction, in seconds.
    public let daylightSavingSeconds: Double

    public init(
        policy: TimeCorrectionPolicy,
        year: Int, month: Int, day: Int,
        hour: Int, minute: Int, second: Int,
        longitudeCorrectionSeconds: Double,
        equationOfTimeSeconds: Double,
        daylightSavingSeconds: Double
    ) {
        self.policy = policy
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.longitudeCorrectionSeconds = longitudeCorrectionSeconds
        self.equationOfTimeSeconds = equationOfTimeSeconds
        self.daylightSavingSeconds = daylightSavingSeconds
    }

    /// Total shift applied to the civil clock reading, in seconds.
    public var totalCorrectionSeconds: Double {
        longitudeCorrectionSeconds + equationOfTimeSeconds - daylightSavingSeconds
    }
}

/// Produces a solar-time correction for a birth moment and location.
public protocol SolarTimeCorrectionProvider: Sendable {
    /// The corrected local clock reading, or `nil` if the correction cannot be produced.
    func solarTimeCorrection(
        for moment: CivilMoment,
        location: CalculationLocation,
        policy: TimeCorrectionPolicy
    ) -> SolarTimeCorrection?
}
