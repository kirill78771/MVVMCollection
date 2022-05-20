import UIKit

/// Works only with UICollectionViewFlowLayout
/// For any custom layout it will not be used
public protocol CollectionComponentViewSizeCalculatorProtocol {
    associatedtype ViewModel

    func calculateSize(
        for viewModel: ViewModel,
        collectionView: UICollectionView,
        layout: UICollectionViewLayout,
        indexPath: IndexPath
    ) -> CGSize
}

private enum Constants {
    /// Set before size calculation to ensure any `layoutSubviews()` modifications applied
    static let reasonablyBigDimension: CGFloat = 10000
}

public final class CollectionComponentAutolayoutSizeCalculator<
    ViewModel,
    ViewFactory: CollectionComponentViewFactoryProtocol,
    ViewModelAssigner: CollectionComponentViewModelAssignerProtocol
>: CollectionComponentViewSizeCalculatorProtocol where
    ViewModelAssigner.ViewModel == ViewModel,
    ViewModelAssigner.View == ViewFactory.View
{
    private let viewFactory: ViewFactory
    private let viewModelAssigner: ViewModelAssigner
    private let minSize: CGSize

    private lazy var view = viewFactory.makeView()
    private lazy var cache = [SizeCacheKey: CGSize]()

    public init(
        viewFactory: ViewFactory,
        viewModelAssigner: ViewModelAssigner,
        minSize: CGSize = .zero
    ) {
        self.viewFactory = viewFactory
        self.viewModelAssigner = viewModelAssigner
        self.minSize = minSize
    }
    
    public func calculateSize(
        for viewModel: ViewModel,
        collectionView: UICollectionView,
        layout: UICollectionViewLayout,
        indexPath: IndexPath
    ) -> CGSize {
        guard let layout = layout as? UICollectionViewFlowLayout else {
            assertionFailure(
                "Incorrect layout type, expected UICollectionViewFlowLayout, got \(type(of: layout))"
            )
            return .zero
        }

        let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout

        let insets = delegate?.collectionView?(
            collectionView,
            layout: layout,
            insetForSectionAt: indexPath.section
        ) ?? layout.sectionInset

        let maxSize = CGSize(
            width: collectionView.bounds.size.width - insets.left - insets.right,
            height: collectionView.bounds.size.height - insets.top - insets.bottom
        )

        func calculateSize() -> CGSize {
            viewModelAssigner.assignViewModel(
                viewModel,
                to: view
            )

            switch layout.scrollDirection {
            case .vertical:
                let fittingSize = CGSize(
                    width: maxSize.width,
                    height: Constants.reasonablyBigDimension
                )
                view.setSizeAndLayout(fittingSize)

                let calculatedHeight = view.systemLayoutSizeFitting(
                    fittingSize,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                ).height.rounded(.awayFromZero)

                return CGSize(
                    width: max(minSize.width, fittingSize.width),
                    height: max(minSize.height, calculatedHeight)
                )

            case .horizontal:
                let fittingSize = CGSize(
                    width: Constants.reasonablyBigDimension,
                    height: maxSize.height
                )
                view.setSizeAndLayout(fittingSize)

                let calculatedWidth = view.systemLayoutSizeFitting(
                    fittingSize,
                    withHorizontalFittingPriority: .fittingSizeLevel,
                    verticalFittingPriority: .required
                ).width.rounded(.awayFromZero)

                return CGSize(
                    width: max(minSize.width, calculatedWidth),
                    height: max(minSize.height, fittingSize.height)
                )

            @unknown default:
                assertionFailure("Unhandled scroll direction")
                return .zero
            }
        }

        if let hashableViewModel = viewModel as? CollectionComponentViewModelHashableContentProtocol {
            let cacheKey = SizeCacheKey(
                viewModelType: ViewModel.self,
                contentHash: hashableViewModel.contentHash,
                maxSize: maxSize,
                minSize: minSize,
                scrollDirection: layout.scrollDirection
            )
            if let cachedSize = cache[cacheKey] {
                return cachedSize
            } else {
                let size = calculateSize()
                cache[cacheKey] = size
                return size
            }
        } else {
            return calculateSize()
        }
    }
}

/// Gathers all parameters affecting final calculated size
private struct SizeCacheKey: Hashable {
    let viewModelType: String
    let contentHash: Int
    let maxSizeWidth: CGFloat
    let maxSizeHeight: CGFloat
    let minSizeWidth: CGFloat
    let minSizeHeight: CGFloat
    let scrollDirection: UICollectionView.ScrollDirection.RawValue

    init(
        viewModelType: Any.Type,
        contentHash: Int,
        maxSize: CGSize,
        minSize: CGSize,
        scrollDirection: UICollectionView.ScrollDirection
    ) {
        self.viewModelType = String(reflecting: viewModelType)
        self.contentHash = contentHash
        self.maxSizeWidth = maxSize.width
        self.maxSizeHeight = maxSize.height
        self.minSizeWidth = minSize.width
        self.minSizeHeight = minSize.height
        self.scrollDirection = scrollDirection.rawValue
    }
}

private extension UIView {
    func setSizeAndLayout(_ size: CGSize) {
        frame.size = size
        setNeedsLayout()
        layoutIfNeeded()
    }
}
