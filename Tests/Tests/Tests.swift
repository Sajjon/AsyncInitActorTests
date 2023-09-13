import XCTest
import Atomics // using version 1.1.0
import Foundation

// MARK: Profile

/// Some shared application data akin to a user, which we only ever want one of, typically saved in keychain.
public struct Profile {
	public typealias ID = UUID
	public let id: ID
	public init(id: ID = .init()) {
		self.id = id
	}
}

// MARK: Keychain mock
actor KeychainMock: GlobalActor {
	var profile: Profile?
	static let shared = KeychainMock()
	func setProfile(profile: Profile) async {
		self.profile = profile
	}
}

struct KeychainProfileProvider {
	typealias Value = Profile
	static func provide() async -> Profile {
		if let profile = await KeychainMock.shared.profile {
			return profile
		}
		let new = Profile()
		await KeychainMock.shared.setProfile(profile: new)
		return new
	}
}

// MARK: ProfileStoreProtocol
public protocol ProfileStoreProtocol {
	static func shared() async -> Self
	func getProfile() async -> Profile
	func setProfile(_ profile: Profile) async
}

// MARK: ManagedAtomicProfileStore

/// A ProfileStore which uses `ManagedAtomicLazyReference` under the hood.
public final actor ManagedAtomicProfileStore: ProfileStoreProtocol {
	private static let managedAtomicLazyRef = ManagedAtomicLazyReference<ManagedAtomicProfileStore>()
	private var profile: Profile
	private init() async {
		self.profile = await KeychainProfileProvider.provide()
	}
}

// MARK: ManagedAtomicProfileStore + ProfileStoreProtocol
extension ManagedAtomicProfileStore {

	public static func shared() async -> ManagedAtomicProfileStore {
		await managedAtomicLazyRef.storeIfNilThenLoad(ManagedAtomicProfileStore())
	}

	public func getProfile() async -> Profile {
		profile
	}
	
	public func setProfile(_ profile: Profile) async {
		self.profile = profile
	}
}


// MARK: ReentrantProfileStore (Dont use)

/// An implementation with reentrancy problems, as shown below.
public final actor ReentrantProfileStore: ProfileStoreProtocol {
	
	private static let metaStore = MetaStore()
	
	private var profile: Profile
	private init() async {
		self.profile = await KeychainProfileProvider.provide()
	}
}

extension ReentrantProfileStore {
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
}

// MARK: ReentrantProfileStore + ProfileStoreProtocol
extension ReentrantProfileStore {

	public static func shared() async -> ReentrantProfileStore {
		await Self.metaStore.shared()
	}
	
	public func getProfile() async -> Profile {
		profile
	}
	
	public func setProfile(_ profile: Profile) async {
		self.profile = profile
	}
}



// MARK: Test Helper

/// This test method has not been implemented with any particular thoughts in mind
/// mostly creating a bunch of unstructured task and reading/setting profile on shared
/// profile store interleaved with some `Task.yield()`'s which seem to what makes
/// the ReentrantProfileStore fail.
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
	XCTAssertEqual(values.count, 1) // will fail for `test_reentrant` sometimes
}

// MARK: Test
final class ProfileStoreTests: XCTestCase {
	
	func test_managed() async {
		await doTestProfileStore(type: ManagedAtomicProfileStore.self)
	}
	
	
	// Fails ~10% of runs
	func test_reentrant() async {
		await doTestProfileStore(type: ReentrantProfileStore.self)
	}

}
