import BaziCore

/// The five-element distribution of a chart, with raw stem/branch/hidden-stem element lists.
public struct FiveElementProfile: Hashable, Sendable, Codable {
    /// Elements of the year/month/day/hour stems.
    public let stemElements: [Element]
    /// Principal elements of the year/month/day/hour branches.
    public let branchElements: [Element]
    /// Elements of every hidden stem across the four branches.
    public let hiddenStemElements: [Element]

    public init(fourPillars: FourPillars) {
        stemElements = [
            fourPillars.year.stem.element,
            fourPillars.month.stem.element,
            fourPillars.day.stem.element,
            fourPillars.hour.stem.element
        ]
        branchElements = [
            fourPillars.year.branch.element,
            fourPillars.month.branch.element,
            fourPillars.day.branch.element,
            fourPillars.hour.branch.element
        ]

        var hidden: [Element] = []
        hidden.reserveCapacity(10)
        Self.appendHiddenStemElements(of: fourPillars.year.branch, to: &hidden)
        Self.appendHiddenStemElements(of: fourPillars.month.branch, to: &hidden)
        Self.appendHiddenStemElements(of: fourPillars.day.branch, to: &hidden)
        Self.appendHiddenStemElements(of: fourPillars.hour.branch, to: &hidden)
        hiddenStemElements = hidden
    }

    /// A tally of stems plus branch principal elements, optionally including hidden stems.
    public func tally(includingHiddenStems: Bool = true) -> [Element: Int] {
        var counts: [Element: Int] = [:]
        counts.reserveCapacity(Element.allCases.count)
        for element in stemElements {
            counts[element, default: 0] += 1
        }
        for element in branchElements {
            counts[element, default: 0] += 1
        }
        if includingHiddenStems {
            for element in hiddenStemElements {
                counts[element, default: 0] += 1
            }
        }
        return counts
    }

    /// The count of a single element in the tally.
    public func count(of element: Element, includingHiddenStems: Bool = true) -> Int {
        tally(includingHiddenStems: includingHiddenStems)[element] ?? 0
    }

    /// Elements with a zero count in the tally, in canonical 五行 order.
    public func missingElements(includingHiddenStems: Bool = true) -> [Element] {
        let counts = tally(includingHiddenStems: includingHiddenStems)
        return Element.allCases.filter { (counts[$0] ?? 0) == 0 }
    }

    /// Elements sharing the highest count, in canonical 五行 order.
    public func dominantElements(includingHiddenStems: Bool = true) -> [Element] {
        let counts = tally(includingHiddenStems: includingHiddenStems)
        guard let maximum = counts.values.max(), maximum > 0 else { return [] }
        return Element.allCases.filter { counts[$0] == maximum }
    }

    private static func appendHiddenStemElements(of branch: EarthlyBranch, to elements: inout [Element]) {
        for hiddenStem in HiddenStemTable.hiddenStems(of: branch) {
            elements.append(hiddenStem.stem.element)
        }
    }
}
