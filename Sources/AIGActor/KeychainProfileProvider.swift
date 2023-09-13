//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-09-13.
//

import Foundation

struct KeychainProfileProvider {
	typealias Value = Profile
	static func provide() async -> Profile {
		.init()
	}
}
