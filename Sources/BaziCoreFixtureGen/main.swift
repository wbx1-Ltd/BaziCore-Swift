import BaziCore
import BaziCoreAstronomy
import BaziCoreTesting
import Foundation

// Regenerates the golden fixtures from our own engines. Usage: swift run BaziCoreFixtureGen [output-dir]

let provider = AstronomicalSolarTermProvider()
let corrector = TrueSolarTimeEngine()

let outputDirectory = CommandLine.arguments.count > 1
    ? URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    : URL(fileURLWithPath: "Tests/BaziCoreFixtureTests/Fixtures", isDirectory: true)

struct InputSpec {
    let id: String
    let year, month, day, hour, minute: Int
    let timeZone: String
    let longitude: Double?
    let latitude: Double?
    let ruleSet: FixtureRuleSet?
    let sources: [String]
    let notes: [String]
}

func makeFixture(_ spec: InputSpec) throws -> GoldenFixture {
    let moment = try CivilMoment(
        year: spec.year, month: spec.month, day: spec.day,
        hour: spec.hour, minute: spec.minute, timeZoneIdentifier: spec.timeZone
    )
    let location: CalculationLocation? = (spec.longitude != nil || spec.latitude != nil)
        ? CalculationLocation(latitude: spec.latitude, longitude: spec.longitude)
        : nil
    let input = BirthInput(moment: moment, location: location)

    var rules = BaziRuleSet.professionalDefault
    if let value = spec.ruleSet?.ziHourPolicy.flatMap(ZiHourPolicy.init(rawValue:)) { rules.ziHourPolicy = value }
    if let value = spec.ruleSet?.timeCorrection.flatMap(TimeCorrectionPolicy.init(rawValue:)) { rules.timeCorrection = value }

    let calculator = BaziCalculator(ruleSet: rules, solarTermProvider: provider, timeCorrectionProvider: corrector)
    let pillars = try calculator.chart(for: input).fourPillars

    return GoldenFixture(
        id: spec.id,
        input: FixtureInput(
            year: spec.year, month: spec.month, day: spec.day,
            hour: spec.hour, minute: spec.minute, timeZone: spec.timeZone,
            longitude: spec.longitude, latitude: spec.latitude
        ),
        ruleSet: spec.ruleSet,
        expected: FixturePillars(
            year: pillars.year.chinese, month: pillars.month.chinese,
            day: pillars.day.chinese, hour: pillars.hour.chinese
        ),
        sources: spec.sources,
        confidence: .canonical,
        notes: spec.notes
    )
}

func write(_ fixtures: [GoldenFixture], to name: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(fixtures)
    let url = outputDirectory.appendingPathComponent(name)
    try (data + Data("\n".utf8)).write(to: url)
    FileHandle.standardError.write(Data("wrote \(fixtures.count) fixtures -> \(name)\n".utf8))
}

// MARK: - Basic charts (non-DST years)

let basic: [InputSpec] = [
    ("basic-1995-summer", 1995, 6, 15, 8, 30),
    ("basic-2000-reference-day", 2000, 1, 7, 12, 0),
    ("basic-1977-autumn", 1977, 9, 20, 3, 15),
    ("basic-2008-olympics", 2008, 8, 8, 20, 8),
    ("basic-2024-midyear", 2024, 6, 15, 12, 0),
    ("basic-2023-zi-month", 2023, 12, 20, 12, 0),
    ("basic-1984-winter", 1984, 12, 25, 6, 0),
    ("basic-2001-spring", 2001, 3, 10, 14, 45),
    ("basic-1966-autumn", 1966, 11, 11, 9, 9),
    ("basic-2019-summer", 2019, 7, 4, 16, 30)
].map { id, y, mo, d, h, mi in
    InputSpec(
        id: id, year: y, month: mo, day: d, hour: h, minute: mi,
        timeZone: "Asia/Shanghai", longitude: nil, latitude: nil, ruleSet: nil,
        sources: ["bazicore"], notes: []
    )
}

// MARK: - Solar-term boundaries (+/- 5 minutes around each Jie term)

let jieTerms: [SolarTermKind] = [
    .liChun, .jingZhe, .qingMing, .liXia, .mangZhong, .xiaoShu,
    .liQiu, .baiLu, .hanLu, .liDong, .daXue, .xiaoHan
]
var boundaries: [InputSpec] = []
var beijing = Calendar(identifier: .gregorian)
beijing.timeZone = TimeZone(identifier: "Asia/Shanghai")!
for term in jieTerms {
    // 小寒 (丑月) opens in January of the following calendar year.
    let termYear = term == .xiaoHan ? 2026 : 2025
    guard let instant = provider.solarTermInstant(term, gregorianYear: termYear) else { continue }
    for (label, delta) in [("before", -5), ("after", 5)] {
        let shifted = instant.date.addingTimeInterval(Double(delta) * 60)
        let c = beijing.dateComponents([.year, .month, .day, .hour, .minute], from: shifted)
        boundaries.append(
            InputSpec(
                id: "term-\(term.chineseName)-\(label)",
                year: c.year!, month: c.month!, day: c.day!, hour: c.hour!, minute: c.minute!,
                timeZone: "Asia/Shanghai", longitude: nil, latitude: nil, ruleSet: nil,
                sources: ["bazicore"],
                notes: ["\(delta >= 0 ? "+" : "")\(delta) min around exact \(term.chineseName)"]
            )
        )
    }
}

// MARK: - Zi-hour policies

func ziRule(_ policy: String?) -> FixtureRuleSet? {
    policy.map { FixtureRuleSet(ziHourPolicy: $0) }
}

let ziHour: [InputSpec] = [
    ("zi-2259-hai-hour", 22, 59, nil, "22:59 is the 亥 hour, before the late-Zi window"),
    ("zi-2300-late-next-day", 23, 0, "lateZiNextDay", "late 子时 rolls the day pillar to the next day"),
    ("zi-2359-late-next-day", 23, 59, "lateZiNextDay", ""),
    ("zi-2300-late-same-day", 23, 0, "lateZiSameDay", "late 子时 keeps the current day pillar"),
    ("zi-0000-early", 0, 0, nil, "early 子时 stays on the calendar day"),
    ("zi-0059-early", 0, 59, nil, ""),
    ("zi-0100-chou", 1, 0, nil, "01:00 is the 丑 hour")
].map { id, h, mi, policy, note in
    InputSpec(
        id: id, year: 2024, month: 6, day: 15, hour: h, minute: mi,
        timeZone: "Asia/Shanghai", longitude: nil, latitude: nil, ruleSet: ziRule(policy),
        sources: ["bazicore", "bazi-rule"], notes: note.isEmpty ? [] : [note]
    )
}

// MARK: - True solar time

let trueSolar: [InputSpec] = [
    ("tst-urumqi-standard-clock", nil, "Ürümqi on Beijing time; civil clock 14:00 is the 未 hour"),
    ("tst-urumqi-local-mean-solar-time", "localMeanSolarTime", "~32.4° west of the 120°E meridian shifts the clock back ~2h10m"),
    ("tst-urumqi-true-solar-time", "trueSolarTime", "longitude correction plus equation of time")
].map { id, policy, note in
    InputSpec(
        id: id, year: 1995, month: 6, day: 15, hour: 14, minute: 0,
        timeZone: "Asia/Shanghai", longitude: 87.6, latitude: 43.8,
        ruleSet: policy.map { FixtureRuleSet(timeCorrection: $0) },
        sources: ["bazicore"], notes: [note]
    )
}

try write(basic.map(makeFixture), to: "four-pillars-basic.json")
try write(boundaries.map(makeFixture), to: "solar-term-boundaries.json")
try write(ziHour.map(makeFixture), to: "zi-hour-policies.json")
try write(trueSolar.map(makeFixture), to: "true-solar-time.json")
