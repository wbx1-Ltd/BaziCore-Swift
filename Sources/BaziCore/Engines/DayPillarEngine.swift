/// Computes the day pillar (日柱) from effective local fields.
public enum DayPillarEngine {
    public struct Result: Sendable {
        public let pillar: Pillar
        /// The effective day used, as a `yyyy-MM-dd` string for the trace.
        public let effectiveDayDescription: String
        public let notes: [BaziComputationNote]
        public let details: [BaziTraceDetail]
    }

    /// Reference day index where 甲子 has cycle index 0.
    private static let jiaZiReferenceJulianDayNumber = 2451551

    /// Computes the day pillar from effective local fields.
    public static func compute(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        dayBoundary: DayBoundaryRule,
        ziHourPolicy: ZiHourPolicy
    ) -> Result {
        let baseJulianDayNumber = GregorianDay.julianDayNumber(year: year, month: month, day: day)
        let isLateZiHour = hour == 23

        var notes: [BaziComputationNote] = []
        var rollForward = false

        switch dayBoundary {
        case .civilMidnight:
            notes.append(.dayBoundaryCivilMidnight)
            if isLateZiHour {
                switch ziHourPolicy {
                case .lateZiNextDay:
                    rollForward = true
                    notes.append(.lateZiHourRolledToNextDay)
                case .lateZiSameDay:
                    notes.append(.lateZiHourKeptSameDay)
                }
            }
        case .ziHourStart:
            notes.append(.dayBoundaryZiHourStart)
            if isLateZiHour {
                rollForward = true
                notes.append(.lateZiHourRolledToNextDay)
            }
        }

        let effectiveJulianDayNumber = baseJulianDayNumber + (rollForward ? 1 : 0)
        let cycleIndex = ModularArithmetic.positiveModulo(
            effectiveJulianDayNumber - jiaZiReferenceJulianDayNumber, 60
        )
        let effectiveDay = GregorianDay(julianDayNumber: effectiveJulianDayNumber)

        let details: [BaziTraceDetail] = [
            BaziTraceDetail(key: .effectiveDay, value: effectiveDay.description)
        ]

        return Result(
            pillar: Pillar(kind: .day, cycle: SexagenaryCycle(index: cycleIndex)),
            effectiveDayDescription: effectiveDay.description,
            notes: notes,
            details: details
        )
    }
}
