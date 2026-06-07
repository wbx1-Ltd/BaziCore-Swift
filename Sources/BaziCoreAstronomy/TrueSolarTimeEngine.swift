import BaziCore
import Foundation

/// Computes local-mean and true (apparent) solar-time corrections from the civil clock.
public struct TrueSolarTimeEngine: SolarTimeCorrectionProvider {
    public init() {}

    public func solarTimeCorrection(
        for moment: CivilMoment,
        location: CalculationLocation,
        policy: TimeCorrectionPolicy
    ) -> SolarTimeCorrection? {
        let instant = moment.instant
        let timeZone = moment.timeZone
        let daylightSaving = timeZone.daylightSavingTimeOffset(for: instant)

        guard policy != .standardClock else {
            return SolarTimeCorrection(
                policy: policy,
                year: moment.year, month: moment.month, day: moment.day,
                hour: moment.hour, minute: moment.minute, second: moment.second,
                longitudeCorrectionSeconds: 0,
                equationOfTimeSeconds: 0,
                daylightSavingSeconds: 0
            )
        }

        guard location.hasValidCoordinates, let longitude = location.longitude else { return nil }

        let currentOffset = Double(timeZone.secondsFromGMT(for: instant))
        let standardOffset = currentOffset - daylightSaving
        // 240 seconds of solar time per degree of longitude.
        let longitudeCorrectionSeconds = longitude * 240.0 - standardOffset
        let equationOfTimeSeconds = policy == .trueSolarTime
            ? EquationOfTime.minutes(at: instant) * 60.0
            : 0.0

        // Effective solar reading = civil reading + (longitude offset + EoT - DST).
        let totalShift = longitudeCorrectionSeconds + equationOfTimeSeconds - daylightSaving

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let naive = DateComponents(
            year: moment.year, month: moment.month, day: moment.day,
            hour: moment.hour, minute: moment.minute, second: moment.second
        )
        guard let base = calendar.date(from: naive) else { return nil }
        let shifted = base.addingTimeInterval(totalShift)
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: shifted
        )
        guard
            let year = components.year, let month = components.month, let day = components.day,
            let hour = components.hour, let minute = components.minute, let second = components.second
        else {
            return nil
        }

        return SolarTimeCorrection(
            policy: policy,
            year: year, month: month, day: day,
            hour: hour, minute: minute, second: second,
            longitudeCorrectionSeconds: longitudeCorrectionSeconds,
            equationOfTimeSeconds: equationOfTimeSeconds,
            daylightSavingSeconds: daylightSaving
        )
    }
}
