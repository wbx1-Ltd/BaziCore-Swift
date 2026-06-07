import BaziCoreTesting
import Testing

@Suite("BaziCoreTestingInfo")
struct BaziCoreTestingInfoTests {
    @Test func exposesModuleName() {
        #expect(BaziCoreTestingInfo.moduleName == "BaziCoreTesting")
    }
}
