import BaziCoreLuck
import Testing

@Suite("BaziCoreLuckInfo")
struct BaziCoreLuckInfoTests {
    @Test func exposesModuleName() {
        #expect(BaziCoreLuckInfo.moduleName == "BaziCoreLuck")
    }
}
