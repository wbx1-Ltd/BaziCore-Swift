/// An optional birth location used for true-solar-time correction.
public struct CalculationLocation: Codable, Hashable, Sendable {
    /// Free-form label for the place (e.g. a city name). Not interpreted.
    public var identifier: String?
    /// Latitude in degrees, north positive. Expected range -90...90.
    public var latitude: Double?
    /// Longitude in degrees, east positive. Expected range -180...180.
    public var longitude: Double?
    /// IANA time-zone identifier for the place, if distinct from the birth moment's zone.
    public var timeZoneIdentifier: String?

    public init(
        identifier: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timeZoneIdentifier: String? = nil
    ) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    public var hasValidCoordinates: Bool {
        (try? validateCoordinates()) != nil
    }

    public func validateCoordinates() throws(BaziError) {
        if let latitude, !Self.isValid(latitude, in: -90...90) {
            throw .invalidCoordinate(detail: "latitude \(latitude) is outside -90...90")
        }
        if let longitude, !Self.isValid(longitude, in: -180...180) {
            throw .invalidCoordinate(detail: "longitude \(longitude) is outside -180...180")
        }
    }

    private static func isValid(_ value: Double, in range: ClosedRange<Double>) -> Bool {
        value.isFinite && range.contains(value)
    }
}
