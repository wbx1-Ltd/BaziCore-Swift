import BaziCore

/// Derives the ten-god (十神) of any stem relative to the day master, by element relation and polarity.
public enum TenGodEngine {
    /// The ten god of `target` relative to `dayMaster`.
    public static func tenGod(of target: HeavenlyStem, dayMaster: HeavenlyStem) -> TenGod {
        let samePolarity = target.yinYang == dayMaster.yinYang
        let masterElement = dayMaster.element
        let targetElement = target.element

        if masterElement == targetElement {
            return samePolarity ? .biJian : .jieCai
        }
        if masterElement.generates(targetElement) {
            return samePolarity ? .shiShen : .shangGuan
        }
        if masterElement.controls(targetElement) {
            return samePolarity ? .pianCai : .zhengCai
        }
        if targetElement.controls(masterElement) {
            return samePolarity ? .qiSha : .zhengGuan
        }
        // Remaining case: the target generates the day master (生我).
        return samePolarity ? .pianYin : .zhengYin
    }

    /// The ten gods of every hidden stem within a branch, paired with their source hidden stems.
    public static func tenGods(
        ofHiddenStemsIn branch: EarthlyBranch,
        dayMaster: HeavenlyStem
    ) -> [(hiddenStem: HiddenStem, tenGod: TenGod)] {
        HiddenStemTable.hiddenStems(of: branch).map { hidden in
            (hidden, tenGod(of: hidden.stem, dayMaster: dayMaster))
        }
    }
}
