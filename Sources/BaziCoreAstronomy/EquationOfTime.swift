import Foundation

/// Equation of time (时差) in minutes: apparent − mean solar time; positive = apparent Sun ahead.
public enum EquationOfTime {
    /// Equation of time in minutes for a Foundation `Date`.
    public static func minutes(at date: Date) -> Double {
        minutes(julianDayUT: date.timeIntervalSince1970 / 86400.0 + 2440587.5)
    }

    /// Equation of time in minutes for a Julian Day (UT).
    public static func minutes(julianDayUT jd: Double) -> Double {
        let t = (jd - 2451545.0) / 36525.0

        let meanLongitude = normalizedDegrees(280.466_46 + 36000.769_83 * t + 0.000_303_2 * t * t)
        let meanAnomaly = 357.529_11 + 35999.050_29 * t - 0.000_153_7 * t * t
        let eccentricity = 0.016_708_634 - 0.000_042_037 * t - 0.000_000_126_7 * t * t
        let obliquity = meanObliquityDegrees(julianCenturies: t)

        let l0 = radians(meanLongitude)
        let m = radians(meanAnomaly)
        let y = pow(tan(radians(obliquity) / 2), 2)

        let value =
            y * sin(2 * l0)
                - 2 * eccentricity * sin(m)
                + 4 * eccentricity * y * sin(m) * cos(2 * l0)
                - 0.5 * y * y * sin(4 * l0)
                - 1.25 * eccentricity * eccentricity * sin(2 * m)

        return 4 * degrees(value)
    }

    /// Mean obliquity of the ecliptic in degrees.
    static func meanObliquityDegrees(julianCenturies t: Double) -> Double {
        23.439_291_1 - 0.013_004_166_7 * t - 1.638e-7 * t * t + 5.036e-7 * t * t * t
    }

    private static func normalizedDegrees(_ degrees: Double) -> Double {
        let value = degrees.truncatingRemainder(dividingBy: 360)
        return value < 0 ? value + 360 : value
    }

    private static func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }

    private static func degrees(_ radians: Double) -> Double {
        radians * 180 / .pi
    }
}
