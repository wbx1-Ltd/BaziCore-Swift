/// Which calendar the birth data originated from.
public enum BirthInputCalendar: String, CaseIterable, Codable, Hashable, Sendable {
    /// The civil moment is a Gregorian (solar) wall-clock date and time.
    case gregorian
    /// Originated from the Chinese lunar calendar, converted to a Gregorian moment before input.
    case chineseLunarConverted
}

/// The complete input to a chart computation: when, optionally where, and the luck-cycle marker.
public struct BirthInput: Codable, Hashable, Sendable {
    /// The validated civil birth moment.
    public var moment: CivilMoment
    /// Optional birth location, required only for solar-time correction.
    public var location: CalculationLocation?
    /// Marker used solely to determine luck-cycle direction; required only for 大运/小运.
    public var sexForLuckCycle: SexForLuckCycle?
    /// Provenance of the birth data.
    public var inputCalendar: BirthInputCalendar

    public init(
        moment: CivilMoment,
        location: CalculationLocation? = nil,
        sexForLuckCycle: SexForLuckCycle? = nil,
        inputCalendar: BirthInputCalendar = .gregorian
    ) {
        self.moment = moment
        self.location = location
        self.sexForLuckCycle = sexForLuckCycle
        self.inputCalendar = inputCalendar
    }
}
