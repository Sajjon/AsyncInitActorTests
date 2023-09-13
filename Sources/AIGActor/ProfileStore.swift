import Atomics

public protocol ProfileStoreProtocol {
	static func shared() async -> Self
	func getProfile() async -> Profile
	func setProfile(_ profile: Profile) async
}

public final actor ManagedAtomicLazyReferenceProfileStore: ProfileStoreProtocol {
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
	public func setProfile(_ profile: Profile) async {
		self.profile = profile
	}
}
