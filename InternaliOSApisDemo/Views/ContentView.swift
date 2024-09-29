//
//  ContentView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NavigationStack {
			Form {
				Section {
					
					NavigationLink {
						RemindersMainView()
					} label: {
						DemoItemListView(icon: "list.bullet", iconBackground: .red, title: "Reminders")
					}

					
					NavigationLink {
						CalendarView()
					} label: {
						DemoItemListView(icon: "calendar", iconBackground: .blue, title: "Calendar")
					}
				}
				
			}
		}
    }
}

struct DemoItemListView: View {
	
	var icon: String
	var iconBackground: Color
	var title: String
	
	var body: some View {
		HStack {
			ZStack {
				RoundedRectangle(cornerRadius: 5)
					.frame(width: 30, height: 30)
					.foregroundStyle(iconBackground)
				
				Image(systemName: icon)
					.foregroundStyle(.white)
					.font(.title3)
				
			}
			
			Text(title)
		}
	}
}

#Preview {
    ContentView()
}
