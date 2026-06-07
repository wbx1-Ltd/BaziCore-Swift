/// The ten Heavenly Stems (天干), ordered 甲…癸 with raw values 0–9.
public enum HeavenlyStem: Int, CaseIterable, Codable, Hashable, Sendable {
    case jia = 0, yi, bing, ding, wu, ji, geng, xin, ren, gui

    /// Creates a stem from any integer index, wrapping cyclically over 10.
    public init(normalizedIndex index: Int) {
        self = HeavenlyStem.allCases[ModularArithmetic.positiveModulo(index, 10)]
    }

    /// Chinese character representation (e.g. "甲").
    public var chinese: String {
        switch self {
        case .jia: "甲"
        case .yi: "乙"
        case .bing: "丙"
        case .ding: "丁"
        case .wu: "戊"
        case .ji: "己"
        case .geng: "庚"
        case .xin: "辛"
        case .ren: "壬"
        case .gui: "癸"
        }
    }

    /// Pinyin with tone marks (e.g. "jiǎ").
    public var pinyin: String {
        switch self {
        case .jia: "jiǎ"
        case .yi: "yǐ"
        case .bing: "bǐng"
        case .ding: "dīng"
        case .wu: "wù"
        case .ji: "jǐ"
        case .geng: "gēng"
        case .xin: "xīn"
        case .ren: "rén"
        case .gui: "guǐ"
        }
    }
}
