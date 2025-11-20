//
//  EntryViews.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI
import SwiftData

// MARK: - CREATE NEW ENTRY
struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var step = 0
    @State private var moodValue: Double = 0.5
    @State private var journalText: String = ""
    @State private var currentPrompt: String = AppContent.randomPrompt()
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            VStack {
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    if step == 1 {
                        Button("Save") { saveEntry() }
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                    }
                }
                .padding()
                
                Spacer()
                
                if step == 0 {
                    MoodSelectionStep(value: $moodValue, onNext: { withAnimation { step = 1 } })
                } else {
                    JournalingStep(text: $journalText, prompt: currentPrompt)
                }
                
                Spacer()
            }
        }
    }
    
    func saveEntry() {
        let entry = JournalEntry(
            moodScore: moodValue,
            prompt: currentPrompt,
            content: journalText
        )
        modelContext.insert(entry)
        dismiss()
    }
}

struct MoodSelectionStep: View {
    @Binding var value: Double
    var onNext: () -> Void
    
    var moodDescription: String {
        switch value {
        case 0..<0.2: return "Heavy"
        case 0.2..<0.4: return "Anxious"
        case 0.4..<0.6: return "Neutral"
        case 0.6..<0.8: return "Calm"
        case 0.8...1.0: return "Radiant"
        default: return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text("How does the present moment feel?")
                .font(.title)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            VStack(spacing: 20) {
                Text(moodDescription.uppercased())
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .liquidGlass()
                    .transition(.opacity)
                    .id(moodDescription)
                
                Slider(value: $value, in: 0...1)
                    .tint(.white)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onNext) {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(Image(systemName: "arrow.right").font(.title2).foregroundColor(.white))
                    .shadow(radius: 10)
            }
            .padding(.top, 30)
        }
    }
}

struct JournalingStep: View {
    @Binding var text: String
    let prompt: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(prompt)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal)
                .shadow(color: .black.opacity(0.3), radius: 2)
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Start writing here...")
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.top, 12)
                        .padding(.leading, 8)
                }
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .font(.body)
                    .lineSpacing(5)
                    .frame(minHeight: 300)
            }
            .padding()
            .liquidGlass()
            .padding(.horizontal)
        }
    }
}

// MARK: - ENTRY DETAILS
struct EntryDetailView: View {
    let entry: JournalEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text(entry.timestamp.formatted(date: .complete, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text(entry.moodLabel.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    Divider().background(.white.opacity(0.2))
                    
                    Text(entry.prompt)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                    
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(8)
                        .padding(.vertical)
                    
                    Spacer(minLength: 40)
                    
                    Button(role: .destructive, action: {
                        modelContext.delete(entry)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Entry")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(16)
                    }
                }
                .padding(24)
                .liquidGlass()
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
