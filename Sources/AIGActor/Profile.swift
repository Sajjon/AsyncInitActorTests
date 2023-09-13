//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-09-13.
//

import Foundation

struct Profile {
	typealias ID = UUID
	let id: ID
	init(id: ID = .init()) {
		self.id = id
	}
}

