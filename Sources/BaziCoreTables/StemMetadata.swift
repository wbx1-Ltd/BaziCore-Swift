import BaziCore

/// The element and polarity carried by a Heavenly Stem.
public struct StemMetadata: Hashable, Sendable, Codable {
    public let stem: HeavenlyStem
    public let element: Element
    public let yinYang: YinYang

    public init(stem: HeavenlyStem, element: Element, yinYang: YinYang) {
        self.stem = stem
        self.element = element
        self.yinYang = yinYang
    }
}

extension HeavenlyStem {
    /// The five-element phase of this stem.
    public var element: Element {
        switch self {
        case .jia, .yi: .wood
        case .bing, .ding: .fire
        case .wu, .ji: .earth
        case .geng, .xin: .metal
        case .ren, .gui: .water
        }
    }

    /// The polarity of this stem. Even raw values are Yang, odd are Yin.
    public var yinYang: YinYang {
        rawValue.isMultiple(of: 2) ? .yang : .yin
    }

    /// Combined metadata for this stem.
    public var metadata: StemMetadata {
        StemMetadata(stem: self, element: element, yinYang: yinYang)
    }
}
