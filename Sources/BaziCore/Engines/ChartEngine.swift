import Foundation

/// Resolves the effective local time and records matching trace notes for the calculator.
enum ChartEngine {
    struct EffectiveTime {
        let year: Int
        let month: Int
        let day: Int
        let hour: Int
        let minute: Int
        let correction: SolarTimeCorrection?
        let notes: [BaziComputationNote]
        let details: [BaziTraceDetail]
    }

    static func resolveEffectiveTime(
        input: BirthInput,
        ruleSet: BaziRuleSet,
        corrector: (any SolarTimeCorrectionProvider)?
    ) throws(BaziError) -> EffectiveTime {
        let moment = input.moment

        guard ruleSet.timeCorrection != .standardClock else {
            return EffectiveTime(
                year: moment.year, month: moment.month, day: moment.day,
                hour: moment.hour, minute: moment.minute,
                correction: nil,
                notes: [.timeUsesStandardClock],
                details: [
                    BaziTraceDetail(
                        key: .originalCivilDateTime,
                        value: TraceFormat.iso(moment.instant),
                        date: moment.instant
                    )
                ]
            )
        }

        guard let location = input.location, location.longitude != nil else {
            throw .missingLocationForTimeCorrection(
                detail: "\(ruleSet.timeCorrection.rawValue) correction requires a location with longitude"
            )
        }
        try location.validateCoordinates()
        guard let corrector else {
            throw .missingLocationForTimeCorrection(
                detail: "\(ruleSet.timeCorrection.rawValue) correction requires a SolarTimeCorrectionProvider"
            )
        }
        guard let correction = corrector.solarTimeCorrection(
            for: moment, location: location, policy: ruleSet.timeCorrection
        ) else {
            throw .missingLocationForTimeCorrection(
                detail: "\(ruleSet.timeCorrection.rawValue) correction could not be produced"
            )
        }

        var notes: [BaziComputationNote] = [
            ruleSet.timeCorrection == .trueSolarTime ? .appliedTrueSolarTime : .appliedLocalMeanSolarTime
        ]
        if correction.daylightSavingSeconds != 0 {
            notes.append(.removedDaylightSavingOffset)
        }

        let details: [BaziTraceDetail] = [
            BaziTraceDetail(key: .originalCivilDateTime, value: TraceFormat.iso(moment.instant), date: moment.instant),
            BaziTraceDetail(
                key: .correctedLocalDateTime,
                value: TraceFormat.localDateTime(
                    year: correction.year, month: correction.month, day: correction.day,
                    hour: correction.hour, minute: correction.minute, second: correction.second
                )
            ),
            BaziTraceDetail(key: .longitudeCorrectionMinutes, value: minutes(correction.longitudeCorrectionSeconds)),
            BaziTraceDetail(key: .equationOfTimeMinutes, value: minutes(correction.equationOfTimeSeconds)),
            BaziTraceDetail(key: .daylightSavingOffsetMinutes, value: minutes(correction.daylightSavingSeconds))
        ]

        return EffectiveTime(
            year: correction.year, month: correction.month, day: correction.day,
            hour: correction.hour, minute: correction.minute,
            correction: correction,
            notes: notes,
            details: details
        )
    }

    private static func minutes(_ seconds: Double) -> String {
        let value = seconds / 60.0
        let scaled = Int((abs(value) * 100.0).rounded())
        let sign = value < 0 && scaled != 0 ? "-" : ""
        let whole = scaled / 100
        let fraction = scaled % 100
        let fractionText = fraction < 10 ? "0\(fraction)" : "\(fraction)"
        return "\(sign)\(whole).\(fractionText)"
    }
}
