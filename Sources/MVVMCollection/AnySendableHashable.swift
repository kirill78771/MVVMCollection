struct AnySendableHashable: @unchecked Sendable, Hashable {
    
    let wrappedValue: AnyHashable
    
    init<T: Hashable>(_ value: T) {
        self.wrappedValue = AnyHashable(value)
    }
}
