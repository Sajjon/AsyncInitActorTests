A PoC highlighting that ManageAtomicLazyRef solves rentrancy problems with naive solution to Asyncronously initialized shared actor [as presented here in Swift Forum Thread](https://forums.swift.org/t/is-this-an-ok-solution-to-achieve-shared-instance-of-actor-using-async-init/63528/2)

# TL;DR

Use `ManagedAtomicLazyReference` inside of [swift-atomics](https://github.com/apple/swift-atomics)

```swift

/// An actor protecting a mutable `value: Value` which is typically a struct, that has to
/// be asyncrounsly created initially
public final actor AsyncInitSharedStoreActor {
	/// Swift Atomics
	private static let atom = ManagedAtomicLazyReference<AsyncInitSharedStoreActor>()
	
	/// Some protected value, typically a struct
	private var value: Value
	
	private init() async {
		/// Typically reading `value` from Keychain or some other async storage
		self.value = await someMethodWhichMustBeAsync() 
	}
}

extension AsyncInitSharedStoreActor {

	public static func shared() async -> AsyncInitSharedStoreActor {
		await atom.storeIfNilThenLoad(AsyncInitSharedStoreActor())
	}

	public func get() async -> Value {
		value
	}

	public func update(_ value: Value) async {
		self.value = value
	}
}
```