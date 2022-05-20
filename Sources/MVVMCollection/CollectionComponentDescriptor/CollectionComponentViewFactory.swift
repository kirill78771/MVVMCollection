import UIKit

public protocol CollectionComponentViewFactoryProtocol {
    associatedtype View: UIView
    func makeView() -> View
}

public struct CollectionComponentInitViewFactory<View: UIView>: CollectionComponentViewFactoryProtocol {
    public init() { }

    public func makeView() -> View {
        View()
    }
}

public struct CollectionComponentBlockViewFactory<View: UIView>: CollectionComponentViewFactoryProtocol {
    private let makeViewBlock: () -> View

    public init(
        makeViewBlock: @escaping () -> View
    ) {
        self.makeViewBlock = makeViewBlock
    }

    public func makeView() -> View {
        makeViewBlock()
    }
}
