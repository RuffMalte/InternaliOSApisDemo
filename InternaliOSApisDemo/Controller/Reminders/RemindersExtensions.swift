//
//  RemindersExtensions.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 29.09.24.
//

import Foundation
import EventKit

extension EKReminder {
	enum Priority: Int, CaseIterable {
		case none = 0
		case high = 1
		case medium = 5
		case low = 9
		
		var name: String {
			switch self {
			case .none: return "None"
			case .high: return "High"
			case .medium: return "Medium"
			case .low: return "Low"
			}
		}
		
	}
	
	var priorityLevel: Priority {
		get {
			return Priority(rawValue: priority) ?? .none
		}
		set {
			priority = newValue.rawValue
		}
	}
	
	
	var priorityDisplay: String {
		switch priorityLevel {
		case .high: return "!!!"
		case .medium: return "!!"
		case .low: return "!"
		case .none: return ""
		}
	}
}
