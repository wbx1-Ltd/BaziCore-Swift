import BaziCore

/// The principal element and polarity carried by an Earthly Branch.
public struct BranchMetadata: Hashable, Sendable, Codable {
    public let branch: EarthlyBranch
    public let element: Element
    public let yinYang: YinYang

    public init(branch: EarthlyBranch, element: Element, yinYang: YinYang) {
        self.branch = branch
        self.element = element
        self.yinYang = yinYang
    }
}

extension EarthlyBranch {
    /// The principal five-element phase of this branch (地支本气).
    public var element: Element {
        switch self {
        case .zi, .hai: .water
        case .yin, .mao: .wood
        case .si, .wu: .fire
        case .shen, .you: .metal
        case .chou, .chen, .wei, .xu: .earth
        }
    }

    /// The positional polarity of this branch; even raw values are Yang, odd are Yin.
    public var yinYang: YinYang {
        rawValue.isMultiple(of: 2) ? .yang : .yin
    }

    /// Combined metadata for this branch.
    public var metadata: BranchMetadata {
        BranchMetadata(branch: self, element: element, yinYang: yinYang)
    }
}
