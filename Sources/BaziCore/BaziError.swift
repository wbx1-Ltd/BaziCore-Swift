import Foundation

/// Errors thrown while validating inputs or computing a chart.
public enum BaziError: Error, Equatable, Hashable, Sendable {
    /// The Gregorian year falls outside the supported range.
    case unsupportedYearRange(year: Int, supported: ClosedRange<Int>)
    /// A civil date/time field is out of range or otherwise malformed.
    case invalidCivilMoment(detail: String)
    /// The IANA time-zone identifier is not recognized.
    case invalidTimeZoneIdentifier(String)
    /// The local wall-clock time is ambiguous (a DST fall-back repeat) and was rejected.
    case ambiguousLocalTime(detail: String)
    /// The local wall-clock time does not exist (a DST spring-forward gap).
    case nonexistentLocalTime(detail: String)
    /// A geographic coordinate is out of range.
    case invalidCoordinate(detail: String)
    /// A solar-term instant could not be resolved by the provider.
    case solarTermUnavailable(term: SolarTermKind, year: Int)
    /// A rule requires a location/longitude that was not supplied.
    case missingLocationForTimeCorrection(detail: String)
    /// A luck-cycle computation requires the ``SexForLuckCycle`` marker.
    case missingSexForLuckCycle
    /// The requested input calendar is not supported in this configuration.
    case unsupportedInputCalendar(detail: String)
}

extension BaziError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedYearRange(let year, let supported):
            "Year \(year) is outside the supported range \(supported.lowerBound)...\(supported.upperBound)."
        case .invalidCivilMoment(let detail):
            "Invalid civil moment: \(detail)"
        case .invalidTimeZoneIdentifier(let identifier):
            "Unknown IANA time-zone identifier: \(identifier)"
        case .ambiguousLocalTime(let detail):
            "Ambiguous local time: \(detail)"
        case .nonexistentLocalTime(let detail):
            "Non-existent local time: \(detail)"
        case .invalidCoordinate(let detail):
            "Invalid coordinate: \(detail)"
        case .solarTermUnavailable(let term, let year):
            "Solar term \(term.chineseName) is unavailable for year \(year)."
        case .missingLocationForTimeCorrection(let detail):
            "Time correction requires a location: \(detail)"
        case .missingSexForLuckCycle:
            "The luck-cycle direction requires a SexForLuckCycle marker."
        case .unsupportedInputCalendar(let detail):
            "Unsupported input calendar: \(detail)"
        }
    }
}
