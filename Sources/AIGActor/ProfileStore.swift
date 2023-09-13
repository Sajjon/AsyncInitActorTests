import Atomics

public protocol ProfileStoreProtocol {
	static func shared() async -> Self
	func getProfile() async -> Profile
	func setProfile(_ profile: Profile) async
}

public final actor ManagedAtomicProfileStore: ProfileStoreProtocol {
	private var profile: Profile
	private init() async {
		self.profile = await KeychainProfileProvider.provide()
	}
}

extension ManagedAtomicProfileStore {

	private static let atom = ManagedAtomicLazyReference<ManagedAtomicProfileStore>()

	public static func shared() async -> ManagedAtomicProfileStore {
		if let apa = atom.load() {
			return apa
		}
		return await atom.storeIfNilThenLoad(ManagedAtomicProfileStore())
	}
	
}

extension ManagedAtomicProfileStore {
	public func getProfile() async -> Profile {
		profile
	}
	public func setProfile(_ profile: Profile) async {
		self.profile = profile
	}
}
