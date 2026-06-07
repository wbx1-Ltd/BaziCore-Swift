/// Supplies exact solar-term boundary instants to the pillar engines.
public protocol SolarTermInstantProvider: Sendable {
    /// The instant of a solar term within the given Gregorian year, or `nil` if unresolvable.
    func solarTermInstant(_ term: SolarTermKind, gregorianYear year: Int) -> SolarTermInstant?

    /// All 24 solar-term instants for the given Gregorian year, in chronological order.
    func solarTermInstants(inGregorianYear year: Int) -> [SolarTermInstant]

    /// What kind of provider this is, recorded in chart provenance.
    var providerKind: BaziProviderKind { get }
}

extension SolarTermInstantProvider {
    /// Default implementation enumerating every term through the single-term API.
    public func solarTermInstants(inGregorianYear year: Int) -> [SolarTermInstant] {
        SolarTermKind.allCases
            .compactMap { solarTermInstant($0, gregorianYear: year) }
            .sorted { $0.julianDayUT < $1.julianDayUT }
    }

    /// High-precision astronomy by default.
    public var providerKind: BaziProviderKind { .astronomy }
}
