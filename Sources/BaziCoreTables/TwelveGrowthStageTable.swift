import BaziCore

/// Computes the twelve growth stages (十二长生) of a stem against any branch.
public enum TwelveGrowthStageTable {
    /// The branch where a stem's 长生 (Growth) stage begins.
    public static func growthOrigin(of stem: HeavenlyStem) -> EarthlyBranch {
        switch stem {
        case .jia: .hai // 甲 长生 在 亥
        case .yi: .wu // 乙 长生 在 午
        case .bing, .wu: .yin // 丙/戊 长生 在 寅
        case .ding, .ji: .you // 丁/己 长生 在 酉
        case .geng: .si // 庚 长生 在 巳
        case .xin: .zi // 辛 长生 在 子
        case .ren: .shen // 壬 长生 在 申
        case .gui: .mao // 癸 长生 在 卯
        }
    }

    /// The growth stage of `stem` at `branch`.
    public static func stage(of stem: HeavenlyStem, at branch: EarthlyBranch) -> TwelveGrowthStage {
        let origin = growthOrigin(of: stem)
        let direction = stem.yinYang == .yang ? 1 : -1
        let offset = ((branch.rawValue - origin.rawValue) * direction % 12 + 12) % 12
        return TwelveGrowthStage.allCases[offset]
    }
}
