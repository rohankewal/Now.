//
//  ContentView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/18/25.
//

import SwiftUI
import SwiftData

// MARK: - DATA MODELS
@Model
class JournalEntry {
    var id: UUID
    var timestamp: Date
    var moodScore: Double // 0.0 to 1.0
    var prompt: String
    var content: String
    
    init(moodScore: Double, prompt: String, content: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.moodScore = moodScore
        self.prompt = prompt
        self.content = content
    }
    
    var moodLabel: String {
        switch moodScore {
        case 0..<0.2: return "Heavy"
        case 0.2..<0.4: return "Anxious"
        case 0.4..<0.6: return "Neutral"
        case 0.6..<0.8: return "Calm"
        case 0.8...1.0: return "Radiant"
        default: return "Present"
        }
    }
}

// MARK: - API MODELS
struct APIQuote: Codable {
    let content: String
    let author: String
}

// MARK: - VIEW MODELS & CONSTANTS
struct AppContent {
    static let prompts = [
        "What is the most important thing to do today?",
        "What is weighing on your mind right now?",
        "Write one thing you are grateful for.",
        "How did you practice discipline today?",
        "What would make today great?",
        "Who can you forgive today?",
        "What is a small win you had recently?",
        "How did you step out of your comfort zone today?",
        "What is draining your energy right now?",
        "What is bringing you energy right now?"
    ]
    
    // Fallback quotes if offline
    static let backupQuotes = [
        "We suffer more often in imagination than in reality. — Seneca",
        "The obstacle is the way. — Marcus Aurelius",
        "He who has a why to live for can bear almost any how. — Nietzsche",
        "Waste no more time arguing what a good man should be. Be one. — Marcus Aurelius",
        "The present moment is filled with joy and happiness. — Thich Nhat Hanh"
    ]
    
    // Keys for saving the daily quote to UserDefaults
    private static let quoteKey = "storedDailyQuote"
    private static let dateKey = "storedDailyQuoteDate"
    
    static func randomPrompt() -> String { prompts.randomElement()! }
    
    // NEW: Smart Daily Quote Fetcher
    static func getDailyQuote() async -> String {
        let defaults = UserDefaults.standard
        
        // 1. Check if we already have a quote saved for TODAY
        if let savedDate = defaults.object(forKey: dateKey) as? Date,
           Calendar.current.isDateInToday(savedDate),
           let savedQuote = defaults.string(forKey: quoteKey) {
            return savedQuote
        }
        
        // 2. If not (or if it's a new day), fetch a fresh one
        let newQuote = await fetchFromAPI()
        
        // 3. Save it for the rest of the day
        defaults.set(newQuote, forKey: quoteKey)
        defaults.set(Date(), forKey: dateKey)
        
        return newQuote
    }
    
    // Private helper to handle the actual networking
    private static func fetchFromAPI() async -> String {
        guard let url = URL(string: "https://api.quotable.io/random?tags=wisdom") else {
            return backupQuotes.randomElement()!
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let quoteData = try JSONDecoder().decode(APIQuote.self, from: data)
            return "\"\(quoteData.content)\" — \(quoteData.author)"
        } catch {
            // If offline, pick a random backup
            return backupQuotes.randomElement()!
        }
    }
}

// MARK: - VISUAL EFFECTS (LIQUID GLASS)

struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

extension View {
    func liquidGlass() -> some View {
        self.modifier(LiquidGlassCard())
    }
}

struct LiquidBackground: View {
    @State private var moveBlobs = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Blob 1: Deep Purple
            Circle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: moveBlobs ? -100 : 100, y: moveBlobs ? -150 : 150)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: moveBlobs)
            
            // Blob 2: Teal/Blue
            Circle()
                .fill(Color.blue.opacity(0.4))
                .frame(width: 350, height: 350)
                .blur(radius: 70)
                .offset(x: moveBlobs ? 120 : -120, y: moveBlobs ? 200 : -200)
                .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: moveBlobs)
            
            // Blob 3: Accent Pink
            Circle()
                .fill(Color.pink.opacity(0.2))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: moveBlobs ? -150 : 150, y: moveBlobs ? 50 : -50)
                .animation(.easeInOut(duration: 15).repeatForever(autoreverses: true), value: moveBlobs)
        }
        .ignoresSafeArea()
        .onAppear {
            moveBlobs.toggle()
        }
    }
}

// MARK: - MAIN CONTENT VIEW
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.timestamp, order: .reverse) private var entries: [JournalEntry]
    @State private var showNewEntrySheet = false
    
    // State for the dynamic quote
    @State private var dailyQuote: String = "Finding wisdom..."
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HeaderView()
                        
                        // Quote now navigates to "Breathing Space"
                        NavigationLink(destination: BreathingSpaceView(quote: dailyQuote)) {
                            QuoteCard(quote: dailyQuote)
                        }
                        .buttonStyle(PlainButtonStyle()) // Prevents default link coloring
                        
                        // New Entry Button
                        Button(action: { showNewEntrySheet = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Check In")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .shadow(color: .white.opacity(0.1), radius: 10)
                        }
                        .padding(.horizontal)
                        
                        if !entries.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("RECENT REFLECTIONS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal)
                                
                                ForEach(entries) { entry in
                                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                                        EntryRow(entry: entry)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    // Enable deletion via Long Press context menu
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteEntry(entry)
                                        } label: {
                                            Label("Delete Entry", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        } else {
                            EmptyStateView()
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewEntrySheet) {
                NewEntryView()
                    .presentationBackground(.ultraThinMaterial)
            }
            // Load the quote (cached or new) when the app appears
            .task {
                dailyQuote = await AppContent.getDailyQuote()
            }
        }
    }
    
    private func deleteEntry(_ entry: JournalEntry) {
        withAnimation {
            modelContext.delete(entry)
        }
    }
}

// MARK: - NEW VIEWS (DETAILS & FEATURES)

/// A detail view to read the full entry and reflect
struct EntryDetailView: View {
    let entry: JournalEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LiquidBackground() // Consistent background
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Meta Header
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
                    
                    // Prompt
                    Text(entry.prompt)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                    
                    // Content
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(8)
                        .padding(.vertical)
                    
                    Spacer(minLength: 40)
                    
                    // Delete Button
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
                .liquidGlass() // Wrap the whole content in a glass card
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

/// A view focused on the quote with a breathing animation
struct BreathingSpaceView: View {
    @State private var breathe = false
    let quote: String // Passed from parent
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            // Breathing Circle
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: breathe ? 300 : 150, height: breathe ? 300 : 150)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathe)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .scaleEffect(breathe ? 1.2 : 0.8)
                        .opacity(breathe ? 0 : 1)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathe)
                )
            
            VStack(spacing: 30) {
                Image(systemName: "wind")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
                
                Text(quote)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                
                Text("Breathe in... Breathe out...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 20)
            }
        }
        .onAppear {
            breathe = true
        }
    }
}

// MARK: - EXISTING SUBVIEWS

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Now.")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 5)
                
                Text(Date().formatted(date: .complete, time: .omitted).uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay(
                    Text("ME")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                )
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

struct QuoteCard: View {
    let quote: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "quote.opening")
                .font(.title2)
                .foregroundColor(.white.opacity(0.5))
            
            Text(quote)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(.white)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                Text("DAILY WISDOM")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                
                // Indicator that this is tappable
                HStack(spacing: 4) {
                    Text("Breathe")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(24)
        .liquidGlass()
        .padding(.horizontal)
    }
}

struct EntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Circle()
                    .fill(entry.moodScore > 0.5 ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .shadow(radius: 5)
                Rectangle()
                    .fill(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                    .frame(width: 1)
            }
            .frame(height: 50)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(entry.moodLabel.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                
                Text(entry.content.isEmpty ? "No text added." : entry.content)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
                .padding()
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 80, height: 80)
                )
            
            Text("No entries yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Reflect on the now. Your journey begins today.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

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

#Preview {
    ContentView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
