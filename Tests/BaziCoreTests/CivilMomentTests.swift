import BaziCore
import Foundation
import Testing

@Suite("CivilMoment validation & instant")
struct CivilMomentTests {
    @Test func resolvesAbsoluteInstant() throws {
        let moment = try CivilMoment(
            year: 2000, month: 1, day: 7, hour: 0, minute: 0, second: 0,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Shanghai"))
        let expected = try #require(calendar.date(
            from: DateComponents(year: 2000, month: 1, day: 7, hour: 0, minute: 0, second: 0)
        ))
        #expect(moment.instant == expected)
        #expect(moment.timeZone.identifier == "Asia/Shanghai")
    }

    @Test func rejectsUnknownTimeZone() {
        #expect(throws: BaziError.invalidTimeZoneIdentifier("Mars/Phobos")) {
            try CivilMoment(
                year: 2000, month: 1, day: 1, hour: 0, minute: 0,
                timeZoneIdentifier: "Mars/Phobos"
            )
        }
    }

    @Test func rejectsYearOutOfRange() {
        #expect(throws: BaziError.self) {
            try CivilMoment(year: 1800, month: 1, day: 1, hour: 0, minute: 0, timeZoneIdentifier: "UTC")
        }
        #expect(throws: BaziError.self) {
            try CivilMoment(year: 2200, month: 1, day: 1, hour: 0, minute: 0, timeZoneIdentifier: "UTC")
        }
    }

    @Test func rejectsInvalidDateFields() {
        #expect(throws: BaziError.self) {
            try CivilMoment(year: 2021, month: 2, day: 29, hour: 0, minute: 0, timeZoneIdentifier: "UTC")
        }
        #expect(throws: BaziError.self) {
            try CivilMoment(year: 2021, month: 13, day: 1, hour: 0, minute: 0, timeZoneIdentifier: "UTC")
        }
        #expect(throws: BaziError.self) {
            try CivilMoment(year: 2021, month: 1, day: 1, hour: 24, minute: 0, timeZoneIdentifier: "UTC")
        }
    }

    @Test func rejectsNonexistentDstGapTime() {
        // US spring-forward 2021-03-14: clocks jump 02:00 -> 03:00, so 02:30 is a gap.
        #expect(throws: BaziError.self) {
            try CivilMoment(
                year: 2021, month: 3, day: 14, hour: 2, minute: 30,
                timeZoneIdentifier: "America/New_York"
            )
        }
    }

    @Test func rejectsAmbiguousDstRepeatByDefault() {
        // US fall-back 2021-11-07: 01:30 occurs twice.
        #expect(throws: BaziError.self) {
            try CivilMoment(
                year: 2021, month: 11, day: 7, hour: 1, minute: 30,
                timeZoneIdentifier: "America/New_York"
            )
        }
    }

    @Test func resolvesAmbiguousDstRepeatWhenAsked() throws {
        let first = try CivilMoment(
            year: 2021, month: 11, day: 7, hour: 1, minute: 30,
            timeZoneIdentifier: "America/New_York", repeatedTimeResolution: .firstOccurrence
        )
        let last = try CivilMoment(
            year: 2021, month: 11, day: 7, hour: 1, minute: 30,
            timeZoneIdentifier: "America/New_York", repeatedTimeResolution: .lastOccurrence
        )
        // The two occurrences are exactly one hour apart.
        #expect(last.instant.timeIntervalSince(first.instant) == 3600)
    }

    @Test func roundTripsThroughCodable() throws {
        let moment = try CivilMoment(
            year: 1984, month: 2, day: 4, hour: 23, minute: 59, second: 30,
            timeZoneIdentifier: "Asia/Shanghai"
        )
        let data = try JSONEncoder().encode(moment)
        let decoded = try JSONDecoder().decode(CivilMoment.self, from: data)
        #expect(decoded == moment)
        #expect(decoded.instant == moment.instant)
    }

    @Test func rejectsInvalidCivilMomentOnDecode() {
        let json = #"{"year":2000,"month":13,"day":1,"hour":0,"minute":0,"second":0,"timeZoneIdentifier":"UTC"}"#
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(CivilMoment.self, from: Data(json.utf8))
        }
    }
}
