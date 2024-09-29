//
//  ReminderDetailView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 28.09.24.
//

import SwiftUI
import EventKit

struct ReminderDetailView: View {
	@Bindable var list: Reminders
	@State var currentList: [EKReminder] = []
	@EnvironmentObject var reminderManager: ReminderManager
	
	@State private var refreshID = UUID()
	
	var body: some View {
		Form {
			Section {
				ForEach(list.reminders, id: \.calendarItemIdentifier) { reminder in
					ReminderMediumCellView(
						reminder: reminder) {
							toggleReminder(reminder)
						} deleteAction: {
							deleteReminder(reminder)
						}
				}
			}
		}
		.id(refreshID)
		.navigationTitle(list.reminderList.title)
	}
	
	private func toggleReminder(_ reminder: EKReminder) {
		reminder.isCompleted.toggle()
		reminderManager.updateReminder(reminder, newCalendarID: nil) { isFinished, error in
			if isFinished {
				print("Reminder updated")
				refreshID = UUID()
			} else if let error = error {
				print("Error updating reminder: \(error.localizedDescription)")
				reminder.isCompleted.toggle() // Revert the change
				refreshID = UUID() // Force view to refresh
			}
		}
	}
	
	private func deleteReminder(_ reminder: EKReminder) {
		reminderManager.deleteReminder(reminder) { finished, error in
			if finished {
				print("Reminder deleted")
				list.reminders.removeAll { $0.calendarItemIdentifier == reminder.calendarItemIdentifier }
				refreshID = UUID() // Force view to refresh
			} else if let error = error {
				print("Error deleting reminder: \(error.localizedDescription)")
			}
		}
	}
}

//#Preview {
//    ReminderDetailView()
//}
