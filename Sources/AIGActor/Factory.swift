import Atomics
import ConcurrencyExtras




final class PseudoBox {
	static let shared = PseudoBox()
	private var atom: ManagedAtomicLazyReference<AnyObject>
	private init() {
		self.atom = .init()
	}
}

extension PseudoBox {
	
	func setValue<T: AnyObject>(_ newValue: T) {
		if let existing = atom.load() {
			guard type(of: existing) == T.self else {
				fatalError("wrong value")
			}
		}

		atom = .init()
		_ = atom.storeIfNilThenLoad(newValue)
	}
	
	func getValue<T: AnyObject>(type: T.Type = T.self) -> T? {
		guard let anyValue = atom.load() else {
			return nil
		}
		guard let value = anyValue as? T else {
			fatalError("wrong type")
		}
		return value
	}
}


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
