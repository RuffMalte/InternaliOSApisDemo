//
//  ReminderListMediumCellView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 28.09.24.
//

import SwiftUI
import EventKit

struct ReminderListMediumCellView: View {
	
	var list: Reminders
	
	
    var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Image(systemName: "list.bullet")
					.bold()
					.padding(10)
					.foregroundStyle(.white)
					.background {
						Circle()
							.foregroundStyle(Color(list.reminderList.cgColor))
					}
				
				Text(list.reminderList.title)
					.font(.system(.headline, design: .rounded, weight: .bold))
				
				Spacer()
				
				Text(list.reminders.filter { !$0.isCompleted }.count, format: .number)
					.font(.system(.title3, design: .monospaced, weight: .bold))
			}
		}
    }
}

//#Preview {
//	ReminderListMediumCellView(title: "Test ME", color: Color.brown)
//}
