import BaziCore

/// The complete luck cycle for a chart: direction, child limit, major luck periods, and minor luck years.
public struct LuckCycle: Hashable, Sendable, Codable {
    public let direction: LuckDirection
    public let childLimit: ChildLimit
    public let daYun: [DaYun]
    public let xiaoYun: [XiaoYun]

    public init(direction: LuckDirection, childLimit: ChildLimit, daYun: [DaYun], xiaoYun: [XiaoYun]) {
        self.direction = direction
        self.childLimit = childLimit
        self.daYun = daYun
        self.xiaoYun = xiaoYun
    }

    /// Computes the full luck cycle from a chart; the chart's input must carry a sex marker for the direction rule.
    public static func compute(
        chart: BaziChart,
        provider: any SolarTermInstantProvider,
        daYunCount: Int = 12,
        xiaoYunCount: Int = 12
    ) throws(BaziError) -> LuckCycle {
        guard let sex = chart.input.sexForLuckCycle else {
            throw .missingSexForLuckCycle
        }
        let birth = chart.input.moment
        let direction = LuckDirection.resolve(yearStem: chart.fourPillars.year.stem, sex: sex)
        let childLimit = try ChildLimitEngine.compute(
            birth: birth, direction: direction, rule: chart.ruleSet.childLimitRule, provider: provider
        )
        let daYun = DaYunEngine.compute(
            monthPillar: chart.fourPillars.month.cycle,
            birthGregorianYear: birth.year,
            childLimit: childLimit,
            direction: direction,
            count: daYunCount
        )
        let xiaoYun = XiaoYun.series(
            hourPillar: chart.fourPillars.hour.cycle,
            birthGregorianYear: birth.year,
            direction: direction,
            count: xiaoYunCount
        )
        return LuckCycle(direction: direction, childLimit: childLimit, daYun: daYun, xiaoYun: xiaoYun)
    }
}
