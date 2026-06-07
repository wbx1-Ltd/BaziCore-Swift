import BaziCore

/// Everything derived for a single pillar.
public struct PillarAnalysis: Hashable, Sendable, Codable {
    public let kind: PillarKind
    public let pillar: Pillar
    public let stemElement: Element
    public let stemYinYang: YinYang
    public let branchElement: Element
    /// Ten god of the stem relative to the day master; `nil` for the day pillar.
    public let stemTenGod: TenGod?
    public let hiddenStems: [HiddenStem]
    /// Ten gods of the hidden stems, in the same order as `hiddenStems`.
    public let hiddenStemTenGods: [TenGod]
    public let naYin: NaYin
    /// The day master's growth stage at this pillar's branch.
    public let growthStage: TwelveGrowthStage
    /// Whether this pillar's branch is void (空亡) for the day pillar's decade.
    public let isVoid: Bool
}

/// A complete chart analysis: per-pillar derivations, five-element profile, void branches, palaces, and ShenSha.
public struct BaziChartAnalysis: Hashable, Sendable, Codable {
    public let dayMaster: HeavenlyStem
    public let pillars: [PillarAnalysis]
    public let fiveElements: FiveElementProfile
    public let voidBranches: VoidBranch
    public let palaces: DestinyPalaces
    public let shenSha: [ShenSha]

    public init(chart: BaziChart, shenShaCatalog: ShenShaCatalog = .ziPingCommon) {
        let dayMaster = chart.dayMaster
        let voidBranches = VoidBranch.forPillar(chart.fourPillars.day.cycle)

        self.dayMaster = dayMaster
        self.voidBranches = voidBranches
        var analyses: [PillarAnalysis] = []
        analyses.reserveCapacity(4)
        analyses.append(Self.analyze(chart.fourPillars.year, dayMaster: dayMaster, voidBranches: voidBranches))
        analyses.append(Self.analyze(chart.fourPillars.month, dayMaster: dayMaster, voidBranches: voidBranches))
        analyses.append(Self.analyze(chart.fourPillars.day, dayMaster: dayMaster, voidBranches: voidBranches))
        analyses.append(Self.analyze(chart.fourPillars.hour, dayMaster: dayMaster, voidBranches: voidBranches))
        pillars = analyses
        fiveElements = FiveElementProfile(fourPillars: chart.fourPillars)
        palaces = DestinyPalaces.compute(fourPillars: chart.fourPillars)
        shenSha = shenShaCatalog.evaluate(chart: chart)
    }

    public var year: PillarAnalysis { pillars[0] }
    public var month: PillarAnalysis { pillars[1] }
    public var day: PillarAnalysis { pillars[2] }
    public var hour: PillarAnalysis { pillars[3] }

    /// ShenSha hits grouped by the pillar they landed on.
    public func shenSha(on kind: PillarKind) -> [ShenSha] {
        shenSha.filter { $0.pillar == kind }
    }

    private static func analyze(
        _ pillar: Pillar,
        dayMaster: HeavenlyStem,
        voidBranches: VoidBranch
    ) -> PillarAnalysis {
        let hidden = HiddenStemTable.hiddenStems(of: pillar.branch)
        var hiddenStemTenGods: [TenGod] = []
        hiddenStemTenGods.reserveCapacity(hidden.count)
        for hiddenStem in hidden {
            hiddenStemTenGods.append(TenGodEngine.tenGod(of: hiddenStem.stem, dayMaster: dayMaster))
        }
        return PillarAnalysis(
            kind: pillar.kind,
            pillar: pillar,
            stemElement: pillar.stem.element,
            stemYinYang: pillar.stem.yinYang,
            branchElement: pillar.branch.element,
            stemTenGod: pillar.kind == .day
                ? nil
                : TenGodEngine.tenGod(of: pillar.stem, dayMaster: dayMaster),
            hiddenStems: hidden,
            hiddenStemTenGods: hiddenStemTenGods,
            naYin: NaYinTable.naYin(for: pillar.cycle),
            growthStage: TwelveGrowthStageTable.stage(of: dayMaster, at: pillar.branch),
            isVoid: voidBranches.contains(pillar.branch)
        )
    }
}

extension BaziChart {
    /// Builds a complete derived analysis of this chart.
    public func analysis(shenShaCatalog: ShenShaCatalog = .ziPingCommon) -> BaziChartAnalysis {
        BaziChartAnalysis(chart: self, shenShaCatalog: shenShaCatalog)
    }
}
