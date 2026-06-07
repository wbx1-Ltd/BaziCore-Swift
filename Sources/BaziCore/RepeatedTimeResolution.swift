/// How to resolve a repeated local wall-clock time during a DST fall-back.
public enum RepeatedTimeResolution: String, CaseIterable, Codable, Hashable, Sendable {
    /// Reject ambiguous wall-clock times and require the caller to choose.
    case reject
    /// Use the first (earlier) occurrence of the repeated local time.
    case firstOccurrence
    /// Use the last (later) occurrence of the repeated local time.
    case lastOccurrence
}
