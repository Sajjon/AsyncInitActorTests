public final actor BadStore<Provider: AsyncValueProvider> {
	public typealias Value = Provider.Value
	public static func shared() async -> Self {
		if let shared: Self = PseudoBox.shared.getValue() {
			return shared
		}
		let newShared = await Self.init()
		PseudoBox.shared.setValue(newShared)
		return newShared
	}
	private let value: Value
	init() async {
		self.value = await Provider.provide()
	}
	public func get() async -> Value {
		value
	}
}
