/// Mathematical helpers shared by the pillar engines.
enum ModularArithmetic {
    /// Euclidean modulo that always returns a non-negative result in `0..<modulus`.
    static func positiveModulo(_ value: Int, _ modulus: Int) -> Int {
        precondition(modulus > 0, "modulus must be positive")
        let remainder = value % modulus
        return remainder >= 0 ? remainder : remainder + modulus
    }
}
