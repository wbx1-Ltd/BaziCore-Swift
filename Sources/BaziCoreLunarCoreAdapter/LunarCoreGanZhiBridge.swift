import BaziCore
import LunarCore

/// Maps sexagenary and solar-term types across the adapter boundary (raw-value parity).
public enum LunarCoreGanZhiBridge {
    // MARK: - Inbound

    public static func heavenlyStem(from tianGan: TianGan) -> HeavenlyStem {
        HeavenlyStem(normalizedIndex: tianGan.rawValue)
    }

    public static func earthlyBranch(from diZhi: DiZhi) -> EarthlyBranch {
        EarthlyBranch(normalizedIndex: diZhi.rawValue)
    }

    public static func sexagenaryCycle(from ganZhi: GanZhi) -> SexagenaryCycle {
        SexagenaryCycle(index: ganZhi.index)
    }

    public static func solarTermKind(from solarTerm: SolarTerm) -> SolarTermKind {
        SolarTermKind.allCases[solarTerm.rawValue]
    }

    // MARK: - Outbound

    public static func tianGan(from stem: HeavenlyStem) -> TianGan {
        TianGan.allCases[stem.rawValue]
    }

    public static func diZhi(from branch: EarthlyBranch) -> DiZhi {
        DiZhi.allCases[branch.rawValue]
    }

    public static func ganZhi(from cycle: SexagenaryCycle) -> GanZhi {
        GanZhi(index: cycle.index)
    }

    public static func solarTerm(from kind: SolarTermKind) -> SolarTerm {
        SolarTerm.allCases[kind.rawValue]
    }
}
