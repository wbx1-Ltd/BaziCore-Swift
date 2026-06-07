import BaziCore

/// Common ShenSha rules: each derives a set of target branches and hits any pillar whose branch matches.
public enum CommonShenShaRule: String, CaseIterable, ShenShaRule, Sendable {
    case tianYiGuiRen
    case taiJiGuiRen
    case wenChangGuiRen
    case taoHua
    case yiMa
    case huaGai
    case jiangXing
    case luShen
    case yangRen
    case hongLuan
    case tianXi
    case guChen
    case guaSu
    case kongWang

    public var identifier: String { rawValue }

    public var source: ShenShaSource { .ziPingClassic }

    public var displayName: String {
        switch self {
        case .tianYiGuiRen: "天乙贵人"
        case .taiJiGuiRen: "太极贵人"
        case .wenChangGuiRen: "文昌贵人"
        case .taoHua: "桃花"
        case .yiMa: "驿马"
        case .huaGai: "华盖"
        case .jiangXing: "将星"
        case .luShen: "禄神"
        case .yangRen: "羊刃"
        case .hongLuan: "红鸾"
        case .tianXi: "天喜"
        case .guChen: "孤辰"
        case .guaSu: "寡宿"
        case .kongWang: "空亡"
        }
    }

    public func evaluate(chart: BaziChart) -> [ShenSha] {
        let targets = targetMask(in: chart)
        guard targets != 0 else { return [] }

        var hits: [ShenSha] = []
        hits.reserveCapacity(4)
        appendHit(for: chart.fourPillars.year, targets: targets, to: &hits)
        appendHit(for: chart.fourPillars.month, targets: targets, to: &hits)
        appendHit(for: chart.fourPillars.day, targets: targets, to: &hits)
        appendHit(for: chart.fourPillars.hour, targets: targets, to: &hits)
        return hits
    }

    func targetBranches(in chart: BaziChart) -> Set<EarthlyBranch> {
        let mask = targetMask(in: chart)
        var branches = Set<EarthlyBranch>()
        branches.reserveCapacity(4)
        for branch in EarthlyBranch.allCases where Self.contains(branch, in: mask) {
            branches.insert(branch)
        }
        return branches
    }

    private func appendHit(for pillar: Pillar, targets: BranchMask, to hits: inout [ShenSha]) {
        guard Self.contains(pillar.branch, in: targets) else { return }
        hits.append(
            ShenSha(
                identifier: identifier,
                displayName: displayName,
                pillar: pillar.kind,
                branch: pillar.branch,
                source: source
            )
        )
    }

    private func targetMask(in chart: BaziChart) -> BranchMask {
        let dayStem = chart.fourPillars.day.stem
        let yearBranch = chart.fourPillars.year.branch
        let dayBranch = chart.fourPillars.day.branch
        switch self {
        case .tianYiGuiRen:
            return Self.tianYi(dayStem)
        case .taiJiGuiRen:
            return Self.taiJi(dayStem)
        case .wenChangGuiRen:
            return Self.mask(Self.wenChang(dayStem))
        case .taoHua:
            return Self.harmonyDerived(yearBranch, dayBranch, table: Self.taoHuaByGroup)
        case .yiMa:
            return Self.harmonyDerived(yearBranch, dayBranch, table: Self.yiMaByGroup)
        case .huaGai:
            return Self.harmonyDerived(yearBranch, dayBranch, table: Self.huaGaiByGroup)
        case .jiangXing:
            return Self.harmonyDerived(yearBranch, dayBranch, table: Self.jiangXingByGroup)
        case .luShen:
            return Self.mask(Self.branch(of: dayStem, stage: .linGuan))
        case .yangRen:
            // 羊刃 applies to Yang day stems only.
            return dayStem.yinYang == .yang ? Self.mask(Self.branch(of: dayStem, stage: .diWang)) : 0
        case .hongLuan:
            return Self.mask(EarthlyBranch(normalizedIndex: 3 - yearBranch.rawValue))
        case .tianXi:
            return Self.mask(EarthlyBranch(normalizedIndex: 9 - yearBranch.rawValue))
        case .guChen:
            return Self.mask(Self.loneliness(yearBranch).gu)
        case .guaSu:
            return Self.mask(Self.loneliness(yearBranch).gua)
        case .kongWang:
            let branches = VoidBranch.forPillar(chart.fourPillars.day.cycle).branches
            return Self.mask(branches[0]) | Self.mask(branches[1])
        }
    }

    // MARK: - Tables

    private typealias BranchMask = UInt16

    private static func mask(_ branch: EarthlyBranch) -> BranchMask {
        1 << BranchMask(branch.rawValue)
    }

    private static func contains(_ branch: EarthlyBranch, in mask: BranchMask) -> Bool {
        mask & Self.mask(branch) != 0
    }

    private static func tianYi(_ stem: HeavenlyStem) -> BranchMask {
        switch stem {
        case .jia, .wu, .geng: mask(.chou) | mask(.wei)
        case .yi, .ji: mask(.zi) | mask(.shen)
        case .bing, .ding: mask(.hai) | mask(.you)
        case .ren, .gui: mask(.mao) | mask(.si)
        case .xin: mask(.yin) | mask(.wu)
        }
    }

    private static func taiJi(_ stem: HeavenlyStem) -> BranchMask {
        switch stem {
        case .jia, .yi: mask(.zi) | mask(.wu)
        case .bing, .ding: mask(.mao) | mask(.you)
        case .wu, .ji: mask(.chen) | mask(.xu) | mask(.chou) | mask(.wei)
        case .geng, .xin: mask(.yin) | mask(.hai)
        case .ren, .gui: mask(.si) | mask(.shen)
        }
    }

    private static func wenChang(_ stem: HeavenlyStem) -> EarthlyBranch {
        switch stem {
        case .jia: .si
        case .yi: .wu
        case .bing, .wu: .shen
        case .ding, .ji: .you
        case .geng: .hai
        case .xin: .zi
        case .ren: .yin
        case .gui: .mao
        }
    }

    /// Triple-harmony group: 0 = 申子辰, 1 = 寅午戌, 2 = 巳酉丑, 3 = 亥卯未.
    private static func harmonyGroup(_ branch: EarthlyBranch) -> Int {
        switch branch {
        case .shen, .zi, .chen: 0
        case .yin, .wu, .xu: 1
        case .si, .you, .chou: 2
        case .hai, .mao, .wei: 3
        }
    }

    private static let taoHuaByGroup: [EarthlyBranch] = [.you, .mao, .wu, .zi]
    private static let yiMaByGroup: [EarthlyBranch] = [.yin, .shen, .hai, .si]
    private static let huaGaiByGroup: [EarthlyBranch] = [.chen, .xu, .chou, .wei]
    private static let jiangXingByGroup: [EarthlyBranch] = [.zi, .wu, .you, .mao]

    private static func harmonyDerived(
        _ first: EarthlyBranch,
        _ second: EarthlyBranch,
        table: [EarthlyBranch]
    ) -> BranchMask {
        mask(table[harmonyGroup(first)]) | mask(table[harmonyGroup(second)])
    }

    /// Seasonal group of the year branch -> (孤辰, 寡宿).
    private static func loneliness(_ branch: EarthlyBranch) -> (gu: EarthlyBranch, gua: EarthlyBranch) {
        switch branch {
        case .hai, .zi, .chou: (.yin, .xu) // winter
        case .yin, .mao, .chen: (.si, .chou) // spring
        case .si, .wu, .wei: (.shen, .chen) // summer
        case .shen, .you, .xu: (.hai, .wei) // autumn
        }
    }

    private static func branch(of stem: HeavenlyStem, stage: TwelveGrowthStage) -> EarthlyBranch {
        EarthlyBranch.allCases.first { TwelveGrowthStageTable.stage(of: stem, at: $0) == stage } ?? .zi
    }
}
