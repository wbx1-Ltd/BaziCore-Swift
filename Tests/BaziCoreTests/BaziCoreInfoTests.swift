import BaziCore
import Testing

@Suite("BaziCoreInfo")
struct BaziCoreInfoTests {
    @Test func exposesDevelopmentVersion() {
        #expect(BaziCoreInfo.version == "1.0.0")
        #expect(BaziCoreInfo.packageName == "BaziCore")
    }
}
