import XCTest
@testable import AIGActor

struct Profile {
	typealias ID = UUID
	let id: ID
	init(id: ID = .init()) {
		self.id = id
	}
}
struct KeychainProfileProvider: AsyncValueProvider {
	typealias Value = Profile
	static func provide() async -> Profile {
		.init()
	}
}

typealias Bad = BadStore<KeychainProfileProvider>

final class AIGActorTests: XCTestCase {
	
	
	/// This test fails in ~30% of cases.
    func test_bad() async {
		let t0 = Task {
			await Bad.shared()
		}
		let t1 = Task {
			await Bad.shared()
		}
		let t2 = Task {
			await Bad.shared()
		}
		let t3 = Task {
			await Bad.shared()
		}
		let t4 = Task {
			await Bad.shared()
		}
		let t5 = Task {
			await Bad.shared()
		}
		let t6 = Task {
			await Bad.shared()
		}
		let t7 = Task {
			await Bad.shared()
		}
		let t8 = Task {
			await Bad.shared()
		}
		let t9 = Task {
			await Bad.shared()
		}
		
		let tasks = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9]
		var values = Set<Profile.ID>()
		for task in tasks {
			let value = await task.value.get().id
			values.insert(value)
		}
		XCTAssertEqual(values.count, 1)
    }
}
