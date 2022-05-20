import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>
typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>

typealias CellRegistrator = (
    _ collectionView: UICollectionView
) -> Void

typealias CellProvider = (
    _ item: AnyHashable,
    _ collectionView: UICollectionView,
    _ indexPath: IndexPath
) -> UICollectionViewCell

typealias CellSizeProvider = (
    _ item: AnyHashable,
    _ collectionView: UICollectionView,
    _ layout: UICollectionViewLayout,
    _ indexPath: IndexPath
) -> CGSize

typealias ViewModelAtIndexPathProvider = (
    _ indexPath: IndexPath
) -> Any?

typealias CellSizeAtIndexPathProvider = (
    _ collectionView: UICollectionView,
    _ layout: UICollectionViewLayout,
    _ indexPath: IndexPath
) -> CGSize?

typealias ItemReloader = (
    _ item: AnyHashable,
    _ animated: Bool
) -> Void

public typealias SupplementaryViewProvider = (
    _ collectionView: UICollectionView,
    _ elementKind: String,
    _ indexPath: IndexPath
) -> UICollectionReusableView?
