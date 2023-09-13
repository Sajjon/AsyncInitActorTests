//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-09-13.
//

import Foundation

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
