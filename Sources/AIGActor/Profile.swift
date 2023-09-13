//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-09-13.
//

import Foundation

public struct Profile {
	public typealias ID = UUID
	public let id: ID
	public init(id: ID = .init()) {
		self.id = id
	}
}

