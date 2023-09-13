import Atomics

public final actor ManagedAtomicLazyReferenceProfileStore {
	private var profile: Profile
	private init() async {
		self.profile = await KeychainProfileProvider.provide()
	}
}

extension ManagedAtomicLazyReferenceProfileStore {

	private static let atom = ManagedAtomicLazyReference<ManagedAtomicLazyReferenceProfileStore>()

	public static func shared() async -> ManagedAtomicLazyReferenceProfileStore {
		if let apa = atom.load() {
			return apa
		}
		return await atom.storeIfNilThenLoad(ManagedAtomicLazyReferenceProfileStore())
	}
	
}

extension ManagedAtomicLazyReferenceProfileStore {
	public func getProfile() async -> Profile {
		profile
	}
}
