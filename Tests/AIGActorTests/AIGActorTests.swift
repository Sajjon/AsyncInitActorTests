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
	let t1 = Task {
		await ProfileStore.shared()
	}
	let t2 = Task {
		await ProfileStore.shared()
	}
	let t3 = Task {
		await ProfileStore.shared()
	}
	let t4 = Task {
		await ProfileStore.shared()
	}
	let t5 = Task {
		await ProfileStore.shared()
	}
	let t6 = Task {
		await ProfileStore.shared()
	}
	let t7 = Task {
		await ProfileStore.shared()
	}
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
		await doTestProfileStore(type: ManagedAtomicLazyReferenceProfileStore.self)
	}
	

}
