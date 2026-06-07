/// The complete result of a chart computation: pillars, input, rule set, and trace.
public struct BaziChart: Codable, Hashable, Sendable {
    /// The birth input the chart was computed from.
    public let input: BirthInput
    /// The rule set in effect.
    public let ruleSet: BaziRuleSet
    /// The four pillars.
    public let fourPillars: FourPillars
    /// Provenance and audit trail.
    public let trace: ComputationTrace

    public init(
        input: BirthInput,
        ruleSet: BaziRuleSet,
        fourPillars: FourPillars,
        trace: ComputationTrace
    ) {
        self.input = input
        self.ruleSet = ruleSet
        self.fourPillars = fourPillars
        self.trace = trace
    }

    /// The day master (日主): the day pillar's Heavenly Stem.
    public var dayMaster: HeavenlyStem {
        fourPillars.dayMaster
    }
}
