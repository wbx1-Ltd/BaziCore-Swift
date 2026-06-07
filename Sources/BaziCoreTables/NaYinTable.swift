import BaziCore

/// The NaYin (纳音) table, indexed by sexagenary-cycle position; each value spans two positions.
public enum NaYinTable {
    /// NaYin for a sexagenary-cycle index (0–59); any integer is wrapped.
    public static func naYin(forCycleIndex index: Int) -> NaYin {
        let normalized = ((index % 60) + 60) % 60
        return table[normalized / 2]
    }

    /// NaYin for a sexagenary pair.
    public static func naYin(for cycle: SexagenaryCycle) -> NaYin {
        naYin(forCycleIndex: cycle.index)
    }

    /// 30 entries; entry i covers cycle indices 2i and 2i+1.
    private static let table: [NaYin] = [
        NaYin(chinese: "海中金", element: .metal),
        NaYin(chinese: "炉中火", element: .fire),
        NaYin(chinese: "大林木", element: .wood),
        NaYin(chinese: "路旁土", element: .earth),
        NaYin(chinese: "剑锋金", element: .metal),
        NaYin(chinese: "山头火", element: .fire),
        NaYin(chinese: "涧下水", element: .water),
        NaYin(chinese: "城头土", element: .earth),
        NaYin(chinese: "白蜡金", element: .metal),
        NaYin(chinese: "杨柳木", element: .wood),
        NaYin(chinese: "泉中水", element: .water),
        NaYin(chinese: "屋上土", element: .earth),
        NaYin(chinese: "霹雳火", element: .fire),
        NaYin(chinese: "松柏木", element: .wood),
        NaYin(chinese: "长流水", element: .water),
        NaYin(chinese: "沙中金", element: .metal),
        NaYin(chinese: "山下火", element: .fire),
        NaYin(chinese: "平地木", element: .wood),
        NaYin(chinese: "壁上土", element: .earth),
        NaYin(chinese: "金箔金", element: .metal),
        NaYin(chinese: "覆灯火", element: .fire),
        NaYin(chinese: "天河水", element: .water),
        NaYin(chinese: "大驿土", element: .earth),
        NaYin(chinese: "钗钏金", element: .metal),
        NaYin(chinese: "桑柘木", element: .wood),
        NaYin(chinese: "大溪水", element: .water),
        NaYin(chinese: "沙中土", element: .earth),
        NaYin(chinese: "天上火", element: .fire),
        NaYin(chinese: "石榴木", element: .wood),
        NaYin(chinese: "大海水", element: .water)
    ]
}
