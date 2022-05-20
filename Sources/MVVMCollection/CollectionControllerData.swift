import UIKit

public protocol CollectionConrollerDataSectionProtocol: Hashable {
    var items: [AnyHashable] { get }
}

public final class CollectionControllerData {
    public init() { }

    var snapshot = Snapshot()

    public init(items: [AnyHashable]) {
        let section = 0
        snapshot.appendSections([section])
        snapshot.appendItems(
            items,
            toSection: section
        )
    }

    public init<Section: CollectionConrollerDataSectionProtocol>(
        sections: [Section]
    ) {
        sections.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(
                section.items,
                toSection: section
            )
        }
    }
}
