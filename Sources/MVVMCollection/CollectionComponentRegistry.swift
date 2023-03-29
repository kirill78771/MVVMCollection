import UIKit

public final class CollectionComponentRegistry {
    var cellRegistrators = [CellRegistrator]()
    var cellProviders = [TypeIdentifier: CellProvider]()
    var cellSizeProviders = [TypeIdentifier: CellSizeProvider]()

    var viewModelStorage: ViewModelStorageProtocol?
    var itemReloader: ItemReloader?

    public init() { }

    public func append<Item: Hashable, ViewModel, View: UIView>(
        _ descriptor: CollectionComponentDescriptor<Item, ViewModel, View>
    ) {
        let typeIdentifier = TypeIdentifier(underlyingType: Item.self)
        let reuseIdentifier = typeIdentifier.stringValue

        cellRegistrators.append({
            $0.register(
                GenericCollectionViewCell<View>.self,
                forCellWithReuseIdentifier: reuseIdentifier
            )
        })

        let obtainViewModel: (AnyHashable) -> ViewModel = { [weak self] item in
            /// UICollectionViewDiffableDataSource forces type erasure for multiple items type support
            let item = item.base as! Item

            guard let viewModelStorage = self?.viewModelStorage else {
                assertionFailure("viewModelStorage must be set in advance")
                return descriptor.makeViewModel(item)
            }
            if let viewModel = viewModelStorage.getViewModel(for: item) as? ViewModel {
                return viewModel
            } else {
                let viewModel = descriptor.makeViewModel(item)
                if let reloadableViewModel = viewModel as? CollectionComponentViewModelReloadableProtocol {
                    reloadableViewModel.storeReloadToken(
                        BlockReloadToken { animated in
                            guard let self = self else {
                                print("[MVVMCollection] WARNING: Attempted to reload \(item) while CollectionController already deallocated")
                                return
                            }
                            guard let itemReloader = self.itemReloader else {
                                assertionFailure("itemReloader must be set in advance")
                                return
                            }
                            itemReloader(item, animated)
                        }
                    )
                }
                viewModelStorage.setViewModel(
                    viewModel: viewModel,
                    for: item
                )
                return viewModel
            }
        }

        cellProviders[typeIdentifier] = { item, collectionView, indexPath in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: reuseIdentifier,
                for: indexPath
            ) as! GenericCollectionViewCell<View>
            cell.viewFactoryBlock = descriptor.makeView

            descriptor.assignViewModel(
                obtainViewModel(item),
                cell.view
            )

            return cell
        }

        if let calculateSize = descriptor.calculateSize {
            cellSizeProviders[typeIdentifier] = { item, collectionView, layout, indexPath in
                calculateSize(
                    obtainViewModel(item),
                    collectionView,
                    layout,
                    indexPath
                )
            }
        }
    }
}
