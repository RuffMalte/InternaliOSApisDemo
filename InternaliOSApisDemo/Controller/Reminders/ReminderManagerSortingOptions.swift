//
//  ReminderManagerSortingOptions.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 27.09.24.
//

import Foundation
import EventKit

enum SortOption: String, CaseIterable {
	case title = "Title"
	case dueDate = "Due Date"
	case priority = "Priority"
}


extension ReminderManager {
	
	func sortReminders() {
		switch sortOption {
		case .title:
			reminders.sort { $0.title < $1.title }
		case .dueDate:
			reminders.sort { ($0.dueDateComponents?.date ?? Date.distantFuture) < ($1.dueDateComponents?.date ?? Date.distantFuture) }
		case .priority:
			reminders.sort { $0.priority > $1.priority }
		}
	}
}
