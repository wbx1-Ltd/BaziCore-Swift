import Foundation

/// A validated civil wall-clock date/time in an IANA time zone, resolved to one absolute instant.
public struct CivilMoment: Codable, Hashable, Sendable {
    /// The Gregorian year range fully supported by the calendar-backed providers.
    public static let supportedYearRange: ClosedRange<Int> = 1900...2100

    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let second: Int
    /// IANA time-zone identifier, e.g. "Asia/Shanghai".
    public let timeZoneIdentifier: String
    /// How a DST fall-back repeat was resolved.
    public let repeatedTimeResolution: RepeatedTimeResolution

    /// Cached absolute instant in Unix-epoch seconds; derived from the fields, never encoded.
    private let instantTimeInterval: Double

    /// The resolved absolute instant.
    public var instant: Date {
        Date(timeIntervalSince1970: instantTimeInterval)
    }

    /// The validated time zone.
    public var timeZone: TimeZone {
        // Force-unwrap is safe: the identifier was validated at init.
        TimeZone(identifier: timeZoneIdentifier)!
    }

    public init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int = 0,
        timeZoneIdentifier: String,
        repeatedTimeResolution: RepeatedTimeResolution = .reject
    ) throws(BaziError) {
        guard Self.supportedYearRange.contains(year) else {
            throw .unsupportedYearRange(year: year, supported: Self.supportedYearRange)
        }
        guard (1...12).contains(month) else {
            throw .invalidCivilMoment(detail: "Month \(month) out of range 1...12")
        }
        guard let maxDay = GregorianDay.daysInMonth(month, year: year), (1...maxDay).contains(day) else {
            throw .invalidCivilMoment(detail: "Day \(day) out of range for \(year)-\(month)")
        }
        guard (0...23).contains(hour) else {
            throw .invalidCivilMoment(detail: "Hour \(hour) out of range 0...23")
        }
        guard (0...59).contains(minute) else {
            throw .invalidCivilMoment(detail: "Minute \(minute) out of range 0...59")
        }
        guard (0...59).contains(second) else {
            throw .invalidCivilMoment(detail: "Second \(second) out of range 0...59")
        }
        guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else {
            throw .invalidTimeZoneIdentifier(timeZoneIdentifier)
        }

        let instant = try Self.resolveInstant(
            year: year, month: month, day: day,
            hour: hour, minute: minute, second: second,
            timeZone: timeZone,
            timeZoneIdentifier: timeZoneIdentifier,
            repeatedTimeResolution: repeatedTimeResolution
        )

        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.timeZoneIdentifier = timeZoneIdentifier
        self.repeatedTimeResolution = repeatedTimeResolution
        self.instantTimeInterval = instant.timeIntervalSince1970
    }

    // MARK: - Instant resolution

    private static func resolveInstant(
        year: Int, month: Int, day: Int,
        hour: Int, minute: Int, second: Int,
        timeZone: TimeZone,
        timeZoneIdentifier: String,
        repeatedTimeResolution: RepeatedTimeResolution
    ) throws(BaziError) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.calendar = calendar
        components.timeZone = timeZone

        // A wall-clock time inside a spring-forward gap is not representable.
        guard components.isValidDate(in: calendar) else {
            throw .nonexistentLocalTime(
                detail: "\(year)-\(month)-\(day) \(hour):\(minute):\(second) does not exist in \(timeZoneIdentifier)"
            )
        }

        guard
            let first = occurrence(of: components, in: calendar, policy: .first),
            let last = occurrence(of: components, in: calendar, policy: .last)
        else {
            throw .invalidCivilMoment(detail: "Could not resolve \(year)-\(month)-\(day) in \(timeZoneIdentifier)")
        }

        guard first != last else {
            return first
        }

        switch repeatedTimeResolution {
        case .reject:
            throw .ambiguousLocalTime(
                detail: "\(hour):\(minute) is repeated in \(timeZoneIdentifier); choose firstOccurrence or lastOccurrence"
            )
        case .firstOccurrence:
            return first
        case .lastOccurrence:
            return last
        }
    }

    private static func occurrence(
        of components: DateComponents,
        in calendar: Calendar,
        policy: Calendar.RepeatedTimePolicy
    ) -> Date? {
        var dayComponents = DateComponents()
        dayComponents.year = components.year
        dayComponents.month = components.month
        dayComponents.day = components.day
        dayComponents.calendar = calendar
        dayComponents.timeZone = components.timeZone

        guard let dayStart = calendar.date(from: dayComponents) else {
            return nil
        }
        return calendar.nextDate(
            after: dayStart.addingTimeInterval(-1),
            matching: components,
            matchingPolicy: .strict,
            repeatedTimePolicy: policy,
            direction: .forward
        )
    }

    // MARK: - Equatable / Hashable

    /// Equality and hashing use the civil fields only, since the instant is derived from them.
    public static func == (lhs: CivilMoment, rhs: CivilMoment) -> Bool {
        lhs.year == rhs.year
            && lhs.month == rhs.month
            && lhs.day == rhs.day
            && lhs.hour == rhs.hour
            && lhs.minute == rhs.minute
            && lhs.second == rhs.second
            && lhs.timeZoneIdentifier == rhs.timeZoneIdentifier
            && lhs.repeatedTimeResolution == rhs.repeatedTimeResolution
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(month)
        hasher.combine(day)
        hasher.combine(hour)
        hasher.combine(minute)
        hasher.combine(second)
        hasher.combine(timeZoneIdentifier)
        hasher.combine(repeatedTimeResolution)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case year, month, day, hour, minute, second
        case timeZoneIdentifier, repeatedTimeResolution
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let year = try container.decode(Int.self, forKey: .year)
        let month = try container.decode(Int.self, forKey: .month)
        let day = try container.decode(Int.self, forKey: .day)
        let hour = try container.decode(Int.self, forKey: .hour)
        let minute = try container.decode(Int.self, forKey: .minute)
        let second = try container.decodeIfPresent(Int.self, forKey: .second) ?? 0
        let timeZoneIdentifier = try container.decode(String.self, forKey: .timeZoneIdentifier)
        let repeatedTimeResolution = try container.decodeIfPresent(
            RepeatedTimeResolution.self,
            forKey: .repeatedTimeResolution
        ) ?? .reject

        // validate via a returning helper to keep typed-throw mapping out of the `self =` block.
        self = try Self.validated(
            year: year, month: month, day: day,
            hour: hour, minute: minute, second: second,
            timeZoneIdentifier: timeZoneIdentifier,
            repeatedTimeResolution: repeatedTimeResolution,
            codingPath: decoder.codingPath
        )
    }

    private static func validated(
        year: Int, month: Int, day: Int,
        hour: Int, minute: Int, second: Int,
        timeZoneIdentifier: String,
        repeatedTimeResolution: RepeatedTimeResolution,
        codingPath: [any CodingKey]
    ) throws -> CivilMoment {
        do {
            return try CivilMoment(
                year: year, month: month, day: day,
                hour: hour, minute: minute, second: second,
                timeZoneIdentifier: timeZoneIdentifier,
                repeatedTimeResolution: repeatedTimeResolution
            )
        } catch {
            throw DecodingError.dataCorrupted(
                .init(codingPath: codingPath, debugDescription: error.localizedDescription)
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(year, forKey: .year)
        try container.encode(month, forKey: .month)
        try container.encode(day, forKey: .day)
        try container.encode(hour, forKey: .hour)
        try container.encode(minute, forKey: .minute)
        try container.encode(second, forKey: .second)
        try container.encode(timeZoneIdentifier, forKey: .timeZoneIdentifier)
        try container.encode(repeatedTimeResolution, forKey: .repeatedTimeResolution)
    }
}
