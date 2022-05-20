import Foundation

func getProtocolSelectors(
    from proto: Protocol,
    isRequiredMethod: Bool = false,
    isInstanceMethod: Bool = true
) -> Set<Selector> {
    var count: UInt32 = 0

    let methodDescriptions = protocol_copyMethodDescriptionList(
        proto,
        isRequiredMethod,
        isInstanceMethod,
        &count
    )

    var selectors = Set<Selector>()

    for i in 0..<count {
        guard let selector = methodDescriptions?[numericCast(i)].name else { continue }
        selectors.insert(selector)
    }

    free(methodDescriptions)

    return selectors
}

func getClassSelectors(
    from cls: AnyClass
) -> Set<Selector> {
    var count: UInt32 = 0

    let methods = class_copyMethodList(cls, &count)

    var selectors = Set<Selector>()

    for i in 0..<count {
        guard let method = methods?[numericCast(i)] else { continue }
        let selector = method_getName(method)
        selectors.insert(selector)
    }

    free(methods)

    return selectors
}
