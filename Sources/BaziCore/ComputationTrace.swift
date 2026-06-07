import Foundation

/// A controlled key for a structured trace measurement behind a boundary decision.
public enum BaziTraceKey: String, CaseIterable, Codable, Hashable, Sendable {
    case liChunInstant
    case comparedYearNumber
    case effectiveYearStem
    case monthBoundaryTerm
    case monthBoundaryInstant
    case effectiveMonthNumber
    case originalCivilDateTime
    case correctedLocalDateTime
    case effectiveDay
    case effectiveHour
    case longitudeCorrectionMinutes
    case equationOfTimeMinutes
    case daylightSavingOffsetMinutes
    case standardMeridianLongitude
    case childLimitBoundaryTerm
    case childLimitBoundaryInstant
    case luckCycleStartDate
}

/// One structured trace measurement: a controlled key, a value, and an optional instant.
public struct BaziTraceDetail: Codable, Hashable, Sendable {
    public var key: BaziTraceKey
    public var value: String
    public var date: Date?

    public init(key: BaziTraceKey, value: String, date: Date? = nil) {
        self.key = key
        self.value = value
        self.date = date
    }
}

/// Provenance and audit trail for a computed chart.
public struct ComputationTrace: Codable, Hashable, Sendable {
    public var provider: BaziProviderKind
    public var confidence: BaziValidationConfidence
    public var notes: [BaziComputationNote]
    public var details: [BaziTraceDetail]
    public var sourceReferences: [String]

    public init(
        provider: BaziProviderKind,
        confidence: BaziValidationConfidence,
        notes: [BaziComputationNote] = [],
        details: [BaziTraceDetail] = [],
        sourceReferences: [String] = []
    ) {
        self.provider = provider
        self.confidence = confidence
        self.notes = notes
        self.details = details
        self.sourceReferences = sourceReferences
    }

    /// Appends a decision note.
    public mutating func add(_ note: BaziComputationNote) {
        notes.append(note)
    }

    /// Appends a structured measurement.
    public mutating func add(_ key: BaziTraceKey, value: String, date: Date? = nil) {
        details.append(BaziTraceDetail(key: key, value: value, date: date))
    }
}
