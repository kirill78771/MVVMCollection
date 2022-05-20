import Foundation

protocol ViewModelStorageProtocol: AnyObject {
    func setViewModel(
        viewModel: Any,
        for item: AnyHashable
    )
    func getViewModel(
        for item: AnyHashable
    ) -> Any?
    func removeUnusedViewModels(
        for data: CollectionControllerData
    )
}

final class ViewModelStorage: ViewModelStorageProtocol {

    private var storage = [AnyHashable: Any]()

    func setViewModel(
        viewModel: Any,
        for item: AnyHashable
    ) {
        storage[item] = viewModel
    }

    func getViewModel(
        for item: AnyHashable
    ) -> Any? {
        storage[item]
    }

    func removeUnusedViewModels(
        for data: CollectionControllerData
    ) {
        let newItems = Set(data.snapshot.itemIdentifiers)
        let oldItems = Set(storage.keys)
        let removedItems = oldItems.subtracting(newItems)
        removedItems.forEach {
            storage[$0] = nil
        }
    }
}
