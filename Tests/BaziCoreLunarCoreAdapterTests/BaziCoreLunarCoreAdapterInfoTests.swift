import BaziCoreLunarCoreAdapter
import Testing

@Suite("BaziCoreLunarCoreAdapterInfo")
struct BaziCoreLunarCoreAdapterInfoTests {
    @Test func exposesModuleName() {
        #expect(BaziCoreLunarCoreAdapterInfo.moduleName == "BaziCoreLunarCoreAdapter")
    }
}
