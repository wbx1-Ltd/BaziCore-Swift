/// The ten gods (十神): the relationship of any stem to the day master.
public enum TenGod: String, CaseIterable, Codable, Hashable, Sendable {
    case biJian // 比肩
    case jieCai // 劫财
    case shiShen // 食神
    case shangGuan // 伤官
    case pianCai // 偏财
    case zhengCai // 正财
    case qiSha // 七杀
    case zhengGuan // 正官
    case pianYin // 偏印
    case zhengYin // 正印

    /// Chinese name (e.g. "比肩").
    public var chinese: String {
        switch self {
        case .biJian: "比肩"
        case .jieCai: "劫财"
        case .shiShen: "食神"
        case .shangGuan: "伤官"
        case .pianCai: "偏财"
        case .zhengCai: "正财"
        case .qiSha: "七杀"
        case .zhengGuan: "正官"
        case .pianYin: "偏印"
        case .zhengYin: "正印"
        }
    }
}
