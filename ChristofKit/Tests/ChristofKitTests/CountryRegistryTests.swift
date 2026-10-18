import Testing
@testable import ChristofKit

@Test func standardRegistryHasUniqueRegions() {
    let regions = CountryRegistry.standard.regions
    #expect(!regions.isEmpty)
    #expect(Set(regions.map(\.id)).count == regions.count)
    #expect(CountryRegistry.standard.profile(for: CountryRegistry.standard.defaultRegion.countryCode) != nil)
}
