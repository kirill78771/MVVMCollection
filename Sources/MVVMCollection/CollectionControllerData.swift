import UIKit

public protocol CollectionConrollerDataSectionProtocol: Hashable {
    var items: [AnyHashable] { get }
}

public final class CollectionControllerData {
    public init() { }

    var snapshot = Snapshot()

    public init(items: [AnyHashable]) {
        let section = AnySendableHashable(0)
        snapshot.appendSections([section])
        snapshot.appendItems(
            items.map { AnySendableHashable($0) },
            toSection: section
        )
    }

    public init<Section: CollectionConrollerDataSectionProtocol>(
        sections: [Section]
    ) {
        sections.forEach { section in
            let anySendableSection = AnySendableHashable(section)
            snapshot.appendSections([anySendableSection])
            snapshot.appendItems(
                section.items.map { AnySendableHashable($0) },
                toSection: anySendableSection
            )
        }
    }
}
