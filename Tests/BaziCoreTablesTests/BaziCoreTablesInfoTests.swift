import BaziCoreTables
import Testing

@Suite("BaziCoreTablesInfo")
struct BaziCoreTablesInfoTests {
    @Test func exposesModuleName() {
        #expect(BaziCoreTablesInfo.moduleName == "BaziCoreTables")
    }
}
