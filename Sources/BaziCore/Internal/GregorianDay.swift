/// A proleptic Gregorian calendar day with integer Julian Day Number support.
struct GregorianDay: Comparable, Hashable, Sendable, CustomStringConvertible {
    let year: Int
    let month: Int
    let day: Int

    init?(year: Int, month: Int, day: Int) {
        guard let maxDay = Self.daysInMonth(month, year: year), (1...maxDay).contains(day) else {
            return nil
        }
        self.year = year
        self.month = month
        self.day = day
    }

    /// Unchecked initializer for values produced by the inverse algorithm.
    private init(uncheckedYear year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// The integer Julian Day Number for this date.
    var julianDayNumber: Int {
        Self.julianDayNumber(year: year, month: month, day: day)
    }

    /// Integer Julian Day Number for arbitrary Gregorian components, without validation.
    static func julianDayNumber(year: Int, month: Int, day: Int) -> Int {
        let a = (month - 14) / 12
        let term1 = 1461 * (year + 4800 + a) / 4
        let term2 = 367 * (month - 2 - 12 * a) / 12
        let term3 = 3 * ((year + 4900 + a) / 100) / 4
        return term1 + term2 - term3 + day - 32075
    }

    /// Reconstructs a date from an integer Julian Day Number.
    init(julianDayNumber jdn: Int) {
        var l = jdn + 68569
        let n = 4 * l / 146097
        l -= (146097 * n + 3) / 4
        let i = 4000 * (l + 1) / 1461001
        l = l - 1461 * i / 4 + 31
        let j = 80 * l / 2447
        let d = l - 2447 * j / 80
        l = j / 11
        let m = j + 2 - 12 * l
        let y = 100 * (n - 49) + i + l
        self.init(uncheckedYear: y, month: m, day: d)
    }

    /// Returns the day `days` calendar days after this one (negative moves back).
    func advanced(byDays days: Int) -> GregorianDay {
        GregorianDay(julianDayNumber: julianDayNumber + days)
    }

    var description: String {
        "\(year)-\(Self.twoDigits(month))-\(Self.twoDigits(day))"
    }

    static func < (lhs: GregorianDay, rhs: GregorianDay) -> Bool {
        lhs.julianDayNumber < rhs.julianDayNumber
    }

    static func isLeapYear(_ year: Int) -> Bool {
        if year.isMultiple(of: 400) { return true }
        if year.isMultiple(of: 100) { return false }
        return year.isMultiple(of: 4)
    }

    static func daysInMonth(_ month: Int, year: Int) -> Int? {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12: 31
        case 4, 6, 9, 11: 30
        case 2: isLeapYear(year) ? 29 : 28
        default: nil
        }
    }

    private static func twoDigits(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
