import BaziCore
import LunarCore

/// GanZhi pillars from the lunar-calendar dependency.
public struct LunarCoreBaziProvider {
    private let calendar: LunarCalendar

    public init(calendar: LunarCalendar = .shared) {
        self.calendar = calendar
    }

    /// Day pillar (continuous sexagenary count).
    public func dayCycle(gregorianYear year: Int, month: Int, day: Int) -> SexagenaryCycle? {
        guard let solar = SolarDate(year: year, month: month, day: day) else { return nil }
        return LunarCoreGanZhiBridge.sexagenaryCycle(from: calendar.dayGanZhi(for: solar))
    }

    /// Month pillar; wrong stem for 子月 (December) — prefer `MonthPillarEngine`.
    public func monthCycle(gregorianYear year: Int, month: Int, day: Int) -> SexagenaryCycle? {
        guard let solar = SolarDate(year: year, month: month, day: day) else { return nil }
        return LunarCoreGanZhiBridge.sexagenaryCycle(from: calendar.monthGanZhi(for: solar))
    }

    /// The year GanZhi by the lunar-new-year boundary (not BaZi's 立春 boundary).
    public func lunarYearCycle(gregorianYear year: Int, month: Int, day: Int) -> SexagenaryCycle? {
        guard
            let solar = SolarDate(year: year, month: month, day: day),
            let lunar = calendar.lunarDate(from: solar)
        else {
            return nil
        }
        return LunarCoreGanZhiBridge.sexagenaryCycle(from: calendar.yearGanZhi(for: lunar.year))
    }
}
