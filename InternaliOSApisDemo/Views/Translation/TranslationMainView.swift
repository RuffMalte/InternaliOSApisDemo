//
//  TranslationMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 01.10.24.
//

import SwiftUI
import Translation

struct TranslationMainView: View {
	@State private var inputText = ""
	@State private var isTranslationPresented = false
	
	
	@State private var configuration: TranslationSession.Configuration?
	let textToTranslate: [String] = ["Hello", "Thank you", "This one Please", "Nice to meet you", "Farewell"]
	@State private var translationRepsone: [TranslationSession.Response]?
	
	
	var body: some View {
		Form {
			Section {
				HStack {
					TextField("Enter text to translate", text: $inputText)
					Spacer()
					Button {
						isTranslationPresented = true
					} label: {
						Image(systemName: "translate")
					}
				}
			} header: {
				Text("Translation Sheet")
			}
			
			
			
			Section {
				Button {
					if configuration == nil {
						configuration = TranslationSession.Configuration(source: .init(identifier: "en-GB"), target: .init(identifier: "ja-JP"))
						return
					}
					
					configuration?.invalidate()
				} label: {
					Label("Translate a Set of Phrases", systemImage: "translate")
				}
				
				ForEach(Array(textToTranslate.enumerated()), id: \.element) { index, orgText in
					VStack {
						HStack {
							Text(orgText)
							Spacer()
							Text("en-US")
								.foregroundStyle(.tint)
								.font(.system(.footnote, design: .rounded, weight: .bold))
						}
						
						if let translatedResponse = translationRepsone?[index] {
							HStack {
								Text(translatedResponse.targetText)
								Spacer()
								Text(translatedResponse.targetLanguage.minimalIdentifier)
									.foregroundStyle(.tint)
									.font(.system(.footnote, design: .rounded, weight: .bold))
							}
						}
					}
				}
			}
		}
		.translationPresentation(isPresented: $isTranslationPresented, text: inputText) { newTranslation in
			inputText = newTranslation
		}
		.translationTask(configuration) { session in
			let request  = textToTranslate.map { TranslationSession.Request(sourceText: $0, clientIdentifier: $0) }
			
			
			if let responses = try? await session.translations(from: request) {
				withAnimation {
					translationRepsone = responses
				}
			}
		}
	}
}

#Preview {
    TranslationMainView()
}
