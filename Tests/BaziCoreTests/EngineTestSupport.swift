import BaziCore
import BaziCoreAstronomy

/// Shared helpers for exercising the pillar engines against the high-precision
/// astronomical solar-term provider.
enum EngineTestSupport {
    static let provider = AstronomicalSolarTermProvider()

    static func moment(
        _ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0,
        tz: String = "Asia/Shanghai"
    ) throws -> CivilMoment {
        try CivilMoment(
            year: year, month: month, day: day, hour: hour, minute: minute,
            timeZoneIdentifier: tz
        )
    }

    static func yearResult(_ moment: CivilMoment) throws -> YearPillarEngine.Result {
        try YearPillarEngine.compute(
            instant: moment.instant, gregorianYear: moment.year,
            rule: .liChunExact, provider: provider
        )
    }

    static func yearAndMonth(_ moment: CivilMoment) throws -> (year: Pillar, month: Pillar) {
        let year = try yearResult(moment)
        let month = try MonthPillarEngine.compute(
            instant: moment.instant, gregorianYear: moment.year,
            yearStem: year.pillar.stem, provider: provider
        )
        return (year.pillar, month.pillar)
    }

    static func dayPillar(
        _ moment: CivilMoment,
        dayBoundary: DayBoundaryRule = .civilMidnight,
        ziHourPolicy: ZiHourPolicy = .lateZiNextDay
    ) -> Pillar {
        DayPillarEngine.compute(
            year: moment.year, month: moment.month, day: moment.day, hour: moment.hour,
            dayBoundary: dayBoundary, ziHourPolicy: ziHourPolicy
        ).pillar
    }

    static func dayAndHour(
        _ moment: CivilMoment,
        dayBoundary: DayBoundaryRule = .civilMidnight,
        ziHourPolicy: ZiHourPolicy = .lateZiNextDay
    ) -> (day: Pillar, hour: Pillar) {
        let day = dayPillar(moment, dayBoundary: dayBoundary, ziHourPolicy: ziHourPolicy)
        let hour = HourPillarEngine.compute(effectiveHour: moment.hour, dayStem: day.stem).pillar
        return (day, hour)
    }
}
