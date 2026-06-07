import BaziCore

/// A single ShenSha rule that evaluates a chart into zero or more hits and carries its provenance.
public protocol ShenShaRule: Sendable {
    var identifier: String { get }
    var displayName: String { get }
    var source: ShenShaSource { get }
    func evaluate(chart: BaziChart) -> [ShenSha]
}
