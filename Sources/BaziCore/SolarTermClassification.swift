/// Whether a solar term is a *Jie* (节) or a *Zhongqi* (中气).
public enum SolarTermCategory: String, CaseIterable, Codable, Hashable, Sendable {
    /// 节 — the twelve terms that open BaZi months.
    case jie
    /// 中气 — the twelve terms that fall between the *Jie* terms.
    case zhongQi

    /// Chinese label (节 / 中气).
    public var chinese: String {
        switch self {
        case .jie: "节"
        case .zhongQi: "中气"
        }
    }
}

/// One of the four seasons.
public enum Season: String, CaseIterable, Codable, Hashable, Sendable {
    case spring
    case summer
    case autumn
    case winter

    /// Chinese label (春 / 夏 / 秋 / 冬).
    public var chinese: String {
        switch self {
        case .spring: "春"
        case .summer: "夏"
        case .autumn: "秋"
        case .winter: "冬"
        }
    }
}

extension SolarTermKind {
    /// Whether this term is a *Jie* (节) or a *Zhongqi* (中气).
    public var category: SolarTermCategory {
        isMonthBoundaryTerm ? .jie : .zhongQi
    }

    /// The season this term belongs to; each season opens at its 立 term and runs six terms.
    public var season: Season {
        switch rawValue {
        case 2...7: .spring // 立春 … 谷雨
        case 8...13: .summer // 立夏 … 大暑
        case 14...19: .autumn // 立秋 … 霜降
        default: .winter // 立冬 … 大寒
        }
    }

    /// Whether this term opens a season (立春, 立夏, 立秋, 立冬).
    public var isSeasonStart: Bool {
        switch self {
        case .liChun, .liXia, .liQiu, .liDong: true
        default: false
        }
    }

    /// Whether this term is an equinox (春分 or 秋分).
    public var isEquinox: Bool {
        self == .chunFen || self == .qiuFen
    }

    /// Whether this term is a solstice (夏至 or 冬至).
    public var isSolstice: Bool {
        self == .xiaZhi || self == .dongZhi
    }
}
