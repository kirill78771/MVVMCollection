import UIKit

final class GenericCollectionViewCell<View: UIView>: UICollectionViewCell {
    /// MUST be set after dequeue
    var viewFactoryBlock: (() -> View)?

    private(set) lazy var view: View = {
        guard let viewFactoryBlock = viewFactoryBlock else {
            assertionFailure("View factory is not set")
            return View()
        }

        let view = viewFactoryBlock()
        view.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        return view
    }()
}

typealias ErrorCollectionViewCell = GenericCollectionViewCell<UILabel>

extension ErrorCollectionViewCell {
    func setup(text: String) {
        viewFactoryBlock = {
            let label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 0
            label.backgroundColor = .red
            label.textColor = .black
            return label
        }
        view.text = text
    }
}

extension UICollectionView {
    func obtainErrorCell(
        with text: String,
        for indexPath: IndexPath
    ) -> UICollectionViewCell {
        let reuseIdentifier = String(reflecting: ErrorCollectionViewCell.self)
        register(
            ErrorCollectionViewCell.self,
            forCellWithReuseIdentifier: reuseIdentifier
        )
        let cell = dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as! ErrorCollectionViewCell
        cell.setup(text: text)
        return cell
    }
}
