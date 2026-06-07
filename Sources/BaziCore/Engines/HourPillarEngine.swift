/// Computes the hour pillar (时柱) from the effective hour and resolved day stem.
public enum HourPillarEngine {
    public struct Result: Sendable {
        public let pillar: Pillar
        public let notes: [BaziComputationNote]
        public let details: [BaziTraceDetail]
    }

    /// Computes the hour pillar.
    public static func compute(effectiveHour: Int, dayStem: HeavenlyStem) -> Result {
        // 子 spans 23:00–00:59, so (hour + 1) / 2 maps each window to its branch.
        let branchIndex = ((effectiveHour + 1) / 2) % 12
        // Hour stem derived from the day stem.
        let stemIndex = ((dayStem.rawValue % 5) * 2 + branchIndex) % 10
        let cycleIndex = ModularArithmetic.positiveModulo(6 * stemIndex - 5 * branchIndex, 60)

        let details: [BaziTraceDetail] = [
            BaziTraceDetail(key: .effectiveHour, value: String(effectiveHour))
        ]

        return Result(
            pillar: Pillar(kind: .hour, cycle: SexagenaryCycle(index: cycleIndex)),
            notes: [],
            details: details
        )
    }
}
