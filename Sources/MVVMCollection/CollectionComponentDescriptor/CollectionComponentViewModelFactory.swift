import Foundation

public protocol CollectionComponentViewModelFactoryProtocol {
    associatedtype Item
    associatedtype ViewModel

    func makeViewModel(
        for item: Item
    ) -> ViewModel
}

public struct CollectionComponentBlockViewModelFactory<Item, ViewModel>: CollectionComponentViewModelFactoryProtocol {
    private let makeViewModelBlock: (Item) -> ViewModel

    public init(
        makeViewModelBlock: @escaping (Item) -> ViewModel
    ) {
        self.makeViewModelBlock = makeViewModelBlock
    }

    public func makeViewModel(for item: Item) -> ViewModel {
        makeViewModelBlock(item)
    }
}

/// If an item is self-sufficient and is able to fulfill a view - this may simplify descriptor
public struct CollectionComponentSelfViewModelFactory<ItemType>: CollectionComponentViewModelFactoryProtocol {
    public init() { }

    public func makeViewModel(
        for item: ItemType
    ) -> ItemType {
        item
    }
}
