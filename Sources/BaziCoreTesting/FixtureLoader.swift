import Foundation

/// Loads golden fixtures from JSON.
public enum FixtureLoader {
    /// Decodes an array of fixtures from a file URL.
    public static func load(from url: URL) throws -> [GoldenFixture] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([GoldenFixture].self, from: data)
    }

    /// Decodes an array of fixtures from raw JSON data.
    public static func load(from data: Data) throws -> [GoldenFixture] {
        try JSONDecoder().decode([GoldenFixture].self, from: data)
    }
}
