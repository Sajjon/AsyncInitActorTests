//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-09-13.
//

import Atomics

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
