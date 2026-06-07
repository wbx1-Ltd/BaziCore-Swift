import BaziCoreAstronomy
import Testing

@Suite("BaziCoreAstronomyInfo")
struct BaziCoreAstronomyInfoTests {
    @Test func exposesModuleName() {
        #expect(BaziCoreAstronomyInfo.moduleName == "BaziCoreAstronomy")
    }
}
