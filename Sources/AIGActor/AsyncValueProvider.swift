//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2023-09-13.
//

import Foundation

public protocol AsyncValueProvider {
	associatedtype Value
	static func provide() async -> Value
}
