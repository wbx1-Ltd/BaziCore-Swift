/// The four pillars (四柱) of a chart: year, month, day, and hour.
public struct FourPillars: Codable, Hashable, Sendable {
    public let year: Pillar
    public let month: Pillar
    public let day: Pillar
    public let hour: Pillar

    public init(year: Pillar, month: Pillar, day: Pillar, hour: Pillar) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
    }

    /// The four pillars in canonical year → hour order.
    public var all: [Pillar] {
        [year, month, day, hour]
    }

    /// The day master (日主 / 日元): the day pillar's Heavenly Stem.
    public var dayMaster: HeavenlyStem {
        day.stem
    }

    /// Space-separated Chinese rendering, e.g. "甲子 丙寅 戊午 壬戌".
    public var chinese: String {
        all.map(\.chinese).joined(separator: " ")
    }
}
