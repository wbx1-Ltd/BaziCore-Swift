import BaziCore
import BaziCoreTables

/// The direction the luck cycle (大运) runs.
public enum LuckDirection: String, CaseIterable, Codable, Hashable, Sendable {
    case forward
    case backward

    /// The traditional direction rule: forward when year-stem polarity matches sex, backward otherwise.
    public static func resolve(yearStem: HeavenlyStem, sex: SexForLuckCycle) -> LuckDirection {
        let isYang = yearStem.yinYang == .yang
        let isMale = sex == .male
        return isYang == isMale ? .forward : .backward
    }

    /// +1 for forward, -1 for backward, for stepping the sexagenary cycle.
    public var step: Int {
        self == .forward ? 1 : -1
    }
}
