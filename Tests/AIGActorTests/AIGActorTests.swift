import XCTest
@testable import AIGActor

/// When run repeatedly 
/// - 10 000 times (takes 30 sec on an M1).
/// - 100 000 times (takes 5 min on an M1).
func doTestProfileStore<ProfileStore: ProfileStoreProtocol>(
	type: ProfileStore.Type = ProfileStore.self
) async {
	let t0 = Task {
		await ProfileStore.shared()
	}
	await Task.yield()
	var profile = await ProfileStore.shared().getProfile()
	await Task.yield()
	let t1 = Task {
		await ProfileStore.shared()
	}
	let t2 = Task {
		await ProfileStore.shared()
	}
	await Task.yield()
	profile = await ProfileStore.shared().getProfile()
	await Task.yield()
	let t3 = Task {
		await ProfileStore.shared()
	}
	await Task.yield()
	await ProfileStore.shared().setProfile(profile)
	await Task.yield()
	let t4 = Task {
		await ProfileStore.shared()
	}
	let t5 = Task {
		await ProfileStore.shared()
	}
	await Task.yield()
	profile = await ProfileStore.shared().getProfile()
	await Task.yield()
	let t6 = Task {
		await ProfileStore.shared()
	}
	let t7 = Task {
		await ProfileStore.shared()
	}
	await Task.yield()
	await ProfileStore.shared().setProfile(profile)
	await Task.yield()
	let t8 = Task {
		await ProfileStore.shared()
	}
	let t9 = Task {
		await ProfileStore.shared()
	}
	
	let tasks = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9]
	var values = Set<Profile.ID>()
	for task in tasks {
		let profile = await task.value.getProfile()
		values.insert(profile.id)
	}
	XCTAssertEqual(values.count, 1)
}

final class ProfileStoreTests: XCTestCase {
	
	func test_managed() async {
		await doTestProfileStore(type: ManagedAtomicProfileStore.self)
	}
	
	
	// Fails after a few runs
	func test_reentrant() async {
		await doTestProfileStore(type: ReentrantProfileStore.self)
	}
	

}


public final actor ReentrantProfileStore: ProfileStoreProtocol {
	public func getProfile() async -> AIGActor.Profile {
		profile
	}
	
	
	private final actor MetaStore {
		private var _shared: ReentrantProfileStore?
		fileprivate func shared() async -> ReentrantProfileStore {
			if let shared = _shared {
				return shared
			}
			let shared = await ReentrantProfileStore()
			_shared = shared
			return shared
		}
	}
	private static let metaStore = MetaStore()

	public static func shared() async -> ReentrantProfileStore {
		await Self.metaStore.shared()
	}
	
	private var profile: Profile
	private init() async {
		self.profile = await KeychainProfileProvider.provide()
	}
	public func setProfile(_ profile: Profile) async {
		self.profile = profile
	}
}
