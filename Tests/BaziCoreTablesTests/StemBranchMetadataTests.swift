import BaziCore
import BaziCoreTables
import Testing

@Suite("Stem & branch metadata")
struct StemBranchMetadataTests {
    @Test func stemElementsAndPolarities() {
        let expected: [(HeavenlyStem, Element, YinYang)] = [
            (.jia, .wood, .yang), (.yi, .wood, .yin),
            (.bing, .fire, .yang), (.ding, .fire, .yin),
            (.wu, .earth, .yang), (.ji, .earth, .yin),
            (.geng, .metal, .yang), (.xin, .metal, .yin),
            (.ren, .water, .yang), (.gui, .water, .yin)
        ]
        for (stem, element, polarity) in expected {
            #expect(stem.element == element)
            #expect(stem.yinYang == polarity)
        }
    }

    @Test func branchElementsAndPolarities() {
        let expected: [(EarthlyBranch, Element, YinYang)] = [
            (.zi, .water, .yang), (.chou, .earth, .yin),
            (.yin, .wood, .yang), (.mao, .wood, .yin),
            (.chen, .earth, .yang), (.si, .fire, .yin),
            (.wu, .fire, .yang), (.wei, .earth, .yin),
            (.shen, .metal, .yang), (.you, .metal, .yin),
            (.xu, .earth, .yang), (.hai, .water, .yin)
        ]
        for (branch, element, polarity) in expected {
            #expect(branch.element == element)
            #expect(branch.yinYang == polarity)
        }
    }

    @Test func elementGenerationAndControlCycles() {
        #expect(Element.wood.generates() == .fire)
        #expect(Element.fire.generates() == .earth)
        #expect(Element.earth.generates() == .metal)
        #expect(Element.metal.generates() == .water)
        #expect(Element.water.generates() == .wood)

        #expect(Element.wood.controls() == .earth)
        #expect(Element.earth.controls() == .water)
        #expect(Element.water.controls() == .fire)
        #expect(Element.fire.controls() == .metal)
        #expect(Element.metal.controls() == .wood)
    }
}
