/// Binary marker used solely to determine luck-cycle (大运) direction; not an identity field.
public enum SexForLuckCycle: String, CaseIterable, Codable, Hashable, Sendable {
    case male
    case female
}
