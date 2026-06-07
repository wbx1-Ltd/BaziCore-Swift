import BaziCore

/// The hidden-stem (藏干) table: ordered stems concealed within each branch, primary qi first.
public enum HiddenStemTable {
    /// The ordered hidden stems of a branch, primary qi first.
    public static func hiddenStems(of branch: EarthlyBranch) -> [HiddenStem] {
        table[branch.rawValue]
    }

    private static let table: [[HiddenStem]] = [
        [HiddenStem(stem: .gui, role: .primaryQi, weight: 100)],
        [
            HiddenStem(stem: .ji, role: .primaryQi, weight: 60),
            HiddenStem(stem: .gui, role: .middleQi, weight: 30),
            HiddenStem(stem: .xin, role: .residualQi, weight: 10)
        ],
        [
            HiddenStem(stem: .jia, role: .primaryQi, weight: 60),
            HiddenStem(stem: .bing, role: .middleQi, weight: 30),
            HiddenStem(stem: .wu, role: .residualQi, weight: 10)
        ],
        [HiddenStem(stem: .yi, role: .primaryQi, weight: 100)],
        [
            HiddenStem(stem: .wu, role: .primaryQi, weight: 60),
            HiddenStem(stem: .yi, role: .middleQi, weight: 30),
            HiddenStem(stem: .gui, role: .residualQi, weight: 10)
        ],
        [
            HiddenStem(stem: .bing, role: .primaryQi, weight: 60),
            HiddenStem(stem: .geng, role: .middleQi, weight: 30),
            HiddenStem(stem: .wu, role: .residualQi, weight: 10)
        ],
        [
            HiddenStem(stem: .ding, role: .primaryQi, weight: 70),
            HiddenStem(stem: .ji, role: .middleQi, weight: 30)
        ],
        [
            HiddenStem(stem: .ji, role: .primaryQi, weight: 60),
            HiddenStem(stem: .ding, role: .middleQi, weight: 30),
            HiddenStem(stem: .yi, role: .residualQi, weight: 10)
        ],
        [
            HiddenStem(stem: .geng, role: .primaryQi, weight: 60),
            HiddenStem(stem: .ren, role: .middleQi, weight: 30),
            HiddenStem(stem: .wu, role: .residualQi, weight: 10)
        ],
        [HiddenStem(stem: .xin, role: .primaryQi, weight: 100)],
        [
            HiddenStem(stem: .wu, role: .primaryQi, weight: 60),
            HiddenStem(stem: .xin, role: .middleQi, weight: 30),
            HiddenStem(stem: .ding, role: .residualQi, weight: 10)
        ],
        [
            HiddenStem(stem: .ren, role: .primaryQi, weight: 70),
            HiddenStem(stem: .jia, role: .middleQi, weight: 30)
        ]
    ]
}
