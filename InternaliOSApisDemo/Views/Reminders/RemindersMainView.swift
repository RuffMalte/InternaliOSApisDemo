//
//  RemindersMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//

import SwiftUI

import EventKit

struct RemindersMainView: View {
	@EnvironmentObject var reminderManager: ReminderManager
	
	@State private var isShowingModifyReminderSheet: Bool = false
	
	var body: some View {
		Form {
			Section {
				Button {
					reminderManager.requestAccess { granted in
						if granted {
							reminderManager.fetchReminderData()
						}
					}
				} label: {
					Label("Request Reminders Access", systemImage: "list.bullet")
				}
			} header: {
				if reminderManager.calendarAccessStatus == .fullAccess {
					Text("Access Granted")
				} else {
					Text("Not Granted")
				}
			}
			
			
			Section {
				ForEach(reminderManager.remindersInList) { list in
					NavigationLink {
						ReminderListDetailView(list: list)
					} label: {
						ReminderListMediumCellView(list: list)
					}
				}
			}
			
			Section {
				List(reminderManager.reminders, id: \.calendarItemIdentifier) { reminder in
					ReminderMediumCellView(
						reminder: reminder) {
							reminder.isCompleted.toggle()
							reminderManager.updateReminder(reminder, newCalendarID: nil) { isFinished, error in
								if isFinished {
									print("Reminder updated")
								}
							}
						} deleteAction: {
							reminderManager.deleteReminder(reminder) { finished, error in
								if finished {
									print("Reminder deleted")
								}
							}
						} 
				}
			} header: {
				Text("Reminders")
			}
		}
		.onChange(of: reminderManager.sortOption) {
			reminderManager.sortReminders()
		}
		.navigationTitle("Reminders")
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					reminderManager.requestAccess { granted in
						if granted {
							let reminder = EKReminder(eventStore: reminderManager.store)
							reminder.title = "New Reminder"
							reminder.notes = "This is a test reminder"
							reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date().addingTimeInterval(3600))
							reminder.priority = 2
							reminder.calendar = reminderManager.store.defaultCalendarForNewReminders()
							
							reminderManager.addReminder(reminder) { success, error in
								if success {
									print("Reminder added successfully")
									reminderManager.fetchReminders()
								} else if let error = error {
									print("Failed to add reminder: \(error.localizedDescription)")
								}
							}
						} else {
							print("Access to reminders not granted")
						}
					}
				} label: {
					Image(systemName: "plus.diamond")
				}
			}
			ToolbarItem(placement: .primaryAction) {
				Button {
					isShowingModifyReminderSheet.toggle()
				} label: {
					Image(systemName: "plus")
				}
			}
		}
		.sheet(isPresented: $isShowingModifyReminderSheet) {
			ModifyReminderView(reminder: EKReminder(eventStore: reminderManager.store))
		}
	}
}

#Preview {
	NavigationStack {
		RemindersMainView()
	}
}
