/// The twelve growth stages (十二长生) a stem passes through across the twelve branches.
public enum TwelveGrowthStage: String, CaseIterable, Codable, Hashable, Sendable {
    case changSheng // 长生
    case muYu // 沐浴
    case guanDai // 冠带
    case linGuan // 临官
    case diWang // 帝旺
    case shuai // 衰
    case bing // 病
    case si // 死
    case mu // 墓
    case jue // 绝
    case tai // 胎
    case yang // 养

    /// Chinese name (e.g. "长生").
    public var chinese: String {
        switch self {
        case .changSheng: "长生"
        case .muYu: "沐浴"
        case .guanDai: "冠带"
        case .linGuan: "临官"
        case .diWang: "帝旺"
        case .shuai: "衰"
        case .bing: "病"
        case .si: "死"
        case .mu: "墓"
        case .jue: "绝"
        case .tai: "胎"
        case .yang: "养"
        }
    }
}
