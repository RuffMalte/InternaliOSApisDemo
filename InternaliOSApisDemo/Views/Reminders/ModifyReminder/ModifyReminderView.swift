//
//  ModifyReminderView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 27.09.24.
//

import SwiftUI
import EventKit

struct ModifyReminderView: View {
	
	var reminder: EKReminder
	
	@State private var title: String = ""
	@State private var notes: String = ""
	
	@State private var isUsingDueDate: Bool = false
	@State private var isShowingDatePickerDate: Bool = false
	@State private var isShowingDatePickerTime: Bool = false

	@State private var dueDate: Date = Date()
	
	@State private var priority: EKReminder.Priority = .none
	
	@State private var selectedListID: String?

	@EnvironmentObject var reminderManager: ReminderManager
	
	init(reminder: EKReminder) {
		self.reminder = reminder
		_title = State(initialValue: reminder.title)
		_notes = State(initialValue: reminder.notes ?? "")
		_isUsingDueDate = State(initialValue: reminder.dueDateComponents != nil)
		_dueDate = State(initialValue: reminder.dueDateComponents?.date ?? Date())
		_priority = State(initialValue: EKReminder.Priority(rawValue: reminder.priority) ?? .none)
		_selectedListID = State(initialValue: reminder.calendar.calendarIdentifier)
	}
	
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Title", text: $title)
					TextField("Notes", text: $notes)
				}
				
				Section {
					
					Toggle(isOn: $isUsingDueDate) {
						HStack {
							ZStack {
								RoundedRectangle(cornerRadius: 5)
									.frame(width: 30, height: 30)
									.foregroundStyle(.red)
								
								Image(systemName: "calendar")
									.foregroundStyle(.white)
									.font(.title3)
							}
							
							VStack(alignment: .leading) {
								Text("Date")
								
								if isUsingDueDate {
									Text(dueDate, format: .dateTime.day(.defaultDigits).month(.defaultDigits).year(.defaultDigits))
										.font(.footnote)
										.foregroundStyle(.tint)
								}
							}
							Spacer()
						}
					}
					.onChange(of: isUsingDueDate, { oldValue, newValue in
						if newValue {
							isShowingDatePickerDate = true
						} else {
							isShowingDatePickerDate = false
							isShowingDatePickerTime = false
						}
					})
					.onTapGesture {
						withAnimation {
							if isUsingDueDate {
								isShowingDatePickerDate.toggle()
							}
						}
					}
					if isShowingDatePickerDate {
						DatePicker(
							selection: $dueDate,
							displayedComponents: .date) {
								
							}
							.datePickerStyle(.graphical)
					}
					
					Toggle(isOn: $isShowingDatePickerTime) {
						HStack {
							ZStack {
								RoundedRectangle(cornerRadius: 5)
									.frame(width: 30, height: 30)
									.foregroundStyle(.blue)
								
								Image(systemName: "clock.fill")
									.foregroundStyle(.white)
									.font(.title3)
							}
							VStack(alignment: .leading) {
								Text("Time")
								
								if isShowingDatePickerTime {
									Text(dueDate, format: .dateTime.hour().minute())
										.font(.footnote)
										.foregroundStyle(.tint)
								}
							}
							Spacer()
						}
					}
					.onTapGesture {
						withAnimation {
							if isUsingDueDate {
								isShowingDatePickerTime.toggle()
							}
						}
					}
					if isShowingDatePickerTime {
						DatePicker(
							selection: $dueDate,
							displayedComponents: .hourAndMinute) {
								
							}
							.datePickerStyle(.wheel)
					}
					
					
					
				}
				
				Section {
					//Repat
					
					//Location
					
					
				
					Picker(selection: $priority) {
						ForEach(EKReminder.Priority.allCases, id: \.rawValue) { prio in
							Text(prio.name)
								.tag(prio)
						}
					} label: {
						HStack {
							ZStack {
								RoundedRectangle(cornerRadius: 5)
									.frame(width: 30, height: 30)
									.foregroundStyle(.red)
								
								Image(systemName: "exclamationmark")
									.foregroundStyle(.white)
									.font(.title3)
							}
							Text("Priority")
							
							Spacer()
							
						}
					}
					
					
					Picker(selection: $selectedListID) {
						ForEach(reminderManager.reminderLists, id: \.calendarIdentifier) { list in
							Text(list.title)
								.tag(list.calendarIdentifier as String?)
						}
					} label: {
						HStack {
							ZStack {
								Circle()
									.frame(width: 30, height: 30)
									.foregroundStyle(.yellow)
								
								Image(systemName: "list.bullet")
									.foregroundStyle(.white)
									.font(.title3)
							}
							Text("List")
							Spacer()
						}
					}
					.pickerStyle(.navigationLink)
				}
			}
			.navigationTitle("Details")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button("Done") {
						reminder.title = title
						reminder.notes = notes
						
						if isUsingDueDate {
							reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.dueDate)
						} else {
							reminder.dueDateComponents = nil
						}
						
						reminder.priority = priority.rawValue
						
						reminderManager.updateReminder(reminder, newCalendarID: selectedListID) { isFinished, error in
							if let error = error {
								print("Error updating reminder: \(error.localizedDescription)")
							} else if isFinished {
								print("Reminder updated successfully")
								dismiss()
							}
						}
					}
					.bold()
				}
				
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", role: .cancel) {
						dismiss()
					}
				}
			}
		}
    }
}

//#Preview {
//    ModifyReminderView()
//}
