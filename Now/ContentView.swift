//
//  ContentView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/18/25.
//

import SwiftUI
import SwiftData
import LocalAuthentication
import UserNotifications

// MARK: - MANAGERS (Logic Layer)

class AuthenticationManager {
    static func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your journal."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            // No biometrics available (or simulator)
            print("Biometrics not available")
            completion(false)
        }
    }
}

class NotificationManager {
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func scheduleDailyReminder(isEnabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        if isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Time to Reflect"
            content.body = "Take a moment to capture the Now."
            content.sound = .default
            
            // Schedule for 8:00 PM every day
            var dateComponents = DateComponents()
            dateComponents.hour = 20 // 8 PM
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "daily-reflection", content: content, trigger: trigger)
            
            center.add(request)
        }
    }
}

// MARK: - DATA MODELS
@Model
class JournalEntry {
    var id: UUID
    var timestamp: Date
    var moodScore: Double
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
        "What would make today great?",
        "Who can you forgive today?",
        "What is a small win you had recently?",
        "What is draining your energy right now?",
        "What is bringing you energy right now?"
    ]
    
    static let backupQuotes = [
        "We suffer more often in imagination than in reality. — Seneca",
        "The obstacle is the way. — Marcus Aurelius",
        "He who has a why to live for can bear almost any how. — Nietzsche",
        "The present moment is filled with joy and happiness. — Thich Nhat Hanh"
    ]
    
    private static let quoteKey = "storedDailyQuote"
    private static let dateKey = "storedDailyQuoteDate"
    
    static func randomPrompt() -> String { prompts.randomElement()! }
    
    static func getDailyQuote() async -> String {
        let defaults = UserDefaults.standard
        if let savedDate = defaults.object(forKey: dateKey) as? Date,
           Calendar.current.isDateInToday(savedDate),
           let savedQuote = defaults.string(forKey: quoteKey) {
            return savedQuote
        }
        let newQuote = await fetchFromAPI()
        defaults.set(newQuote, forKey: quoteKey)
        defaults.set(Date(), forKey: dateKey)
        return newQuote
    }
    
    private static func fetchFromAPI() async -> String {
        guard let url = URL(string: "https://api.quotable.io/random?tags=wisdom") else {
            return backupQuotes.randomElement()!
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let quoteData = try JSONDecoder().decode(APIQuote.self, from: data)
            return "\"\(quoteData.content)\" — \(quoteData.author)"
        } catch {
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

// MARK: - ROOT VIEW (ORCHESTRATOR)
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("isAppLocked") var isAppLocked: Bool = false
    @AppStorage("isFaceIDEnabled") var isFaceIDEnabled: Bool = false
    
    var body: some View {
        ZStack {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if isAppLocked && isFaceIDEnabled {
                LockView()
            } else {
                JournalHomeView()
            }
        }
        .animation(.easeInOut, value: hasCompletedOnboarding)
        .animation(.easeInOut, value: isAppLocked)
    }
}

// MARK: - ONBOARDING FLOW
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("userName") var userName: String = ""
    @State private var currentTab = 0
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            TabView(selection: $currentTab) {
                // Step 1: Welcome
                VStack(spacing: 20) {
                    Text("Now.")
                        .font(.system(size: 60, weight: .bold, design: .serif))
                    Text("Your space for clarity,\npresence, and peace.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .opacity(0.8)
                }
                .tag(0)
                
                // Step 2: Name
                VStack(spacing: 30) {
                    Text("What should we call you?")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    TextField("Your Name", text: $userName)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .tint(.white)
                }
                .tag(1)
                
                // Step 3: Notifications
                VStack(spacing: 30) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 60))
                        .opacity(0.8)
                    
                    Text("Consistency is key.")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Allow us to gently nudge you to\nreturn to the present moment.")
                        .multilineTextAlignment(.center)
                        .opacity(0.7)
                        .padding(.horizontal)
                    
                    Button("Enable Reminders") {
                        NotificationManager.requestPermission { granted in
                            if granted {
                                NotificationManager.scheduleDailyReminder(isEnabled: true)
                                UserDefaults.standard.set(true, forKey: "areNotificationsEnabled")
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(25)
                }
                .tag(2)
                
                // Step 4: Finish
                VStack(spacing: 30) {
                    Text("You are ready.")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        withAnimation {
                            if userName.isEmpty { userName = "Traveler" }
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Begin Journey")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                }
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .foregroundColor(.white)
        }
    }
}

// MARK: - LOCK SCREEN (FACE ID)
struct LockView: View {
    @AppStorage("isAppLocked") var isAppLocked: Bool = false
    @State private var shake = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LiquidBackground()
                .blur(radius: 20) // Heavier blur for privacy
            
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Now. is Locked")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Button("Unlock") {
                    unlockApp()
                }
                .padding(.top, 20)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .offset(x: shake ? 10 : 0)
            .animation(.default.repeatCount(3).speed(4), value: shake)
        }
        .onAppear {
            unlockApp()
        }
    }
    
    func unlockApp() {
        AuthenticationManager.authenticate { success in
            if success {
                withAnimation {
                    isAppLocked = false
                }
            } else {
                // Haptic feedback or shake animation could go here
                shake.toggle()
            }
        }
    }
}

// MARK: - MAIN APP CONTENT (HOME)
struct JournalHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.timestamp, order: .reverse) private var entries: [JournalEntry]
    @AppStorage("userName") var userName: String = "Traveler"
    
    @State private var showNewEntrySheet = false
    @State private var showProfileSheet = false
    @State private var dailyQuote: String = "Finding wisdom..."
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HeaderView(userName: userName, onProfileTap: {
                            showProfileSheet = true
                        })
                        
                        NavigationLink(destination: BreathingSpaceView(quote: dailyQuote)) {
                            QuoteCard(quote: dailyQuote)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
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
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
                    .presentationBackground(.ultraThinMaterial)
            }
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

// MARK: - PROFILE VIEW (FUNCTIONAL)
struct ProfileView: View {
    @Query private var entries: [JournalEntry]
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("userName") var userName: String = "Traveler"
    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("isFaceIDEnabled") var isFaceIDEnabled: Bool = false

    var totalEntries: Int { entries.count }
    var currentStreak: Int { return entries.isEmpty ? 0 : 1 } // Simplified
    
    var averageMood: String {
        if entries.isEmpty { return "N/A" }
        let total = entries.reduce(0) { $0 + $1.moodScore }
        let average = total / Double(entries.count)
        switch average {
        case 0..<0.2: return "Heavy"
        case 0.2..<0.4: return "Anxious"
        case 0.4..<0.6: return "Neutral"
        case 0.6..<0.8: return "Calm"
        case 0.8...1.0: return "Radiant"
        default: return "Present"
        }
    }

    var body: some View {
        ZStack {
            LiquidBackground()

            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Text("Profile")
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)

                    VStack(spacing: 12) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(userName.prefix(1).uppercased())
                                    .font(.system(size: 40, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            .shadow(radius: 10)

                        Text(userName)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("Mindful Member")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical)

                    HStack(spacing: 12) {
                        StatCard(title: "Entries", value: "\(totalEntries)")
                        StatCard(title: "Day Streak", value: "\(currentStreak)")
                        StatCard(title: "Avg Mood", value: averageMood)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 8)
                            .padding(.top, 10)

                        // Functional Notification Toggle
                        Toggle(isOn: $areNotificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill").frame(width: 24)
                                Text("Daily Reminders (8 PM)")
                            }
                        }
                        .padding()
                        .liquidGlass()
                        .foregroundColor(.white)
                        .onChange(of: areNotificationsEnabled) { oldValue, newValue in
                            if newValue {
                                NotificationManager.requestPermission { granted in
                                    if granted {
                                        NotificationManager.scheduleDailyReminder(isEnabled: true)
                                    } else {
                                        areNotificationsEnabled = false // Revert if denied
                                    }
                                }
                            } else {
                                NotificationManager.scheduleDailyReminder(isEnabled: false)
                            }
                        }

                        // Functional FaceID Toggle
                        Toggle(isOn: $isFaceIDEnabled) {
                            HStack {
                                Image(systemName: "faceid").frame(width: 24)
                                Text("Face ID Lock")
                            }
                        }
                        .padding()
                        .liquidGlass()
                        .foregroundColor(.white)
                        .onChange(of: isFaceIDEnabled) { oldValue, newValue in
                            if newValue {
                                // Authenticate before enabling to ensure it works
                                AuthenticationManager.authenticate { success in
                                    if !success { isFaceIDEnabled = false }
                                }
                            }
                        }
                        
                        // Export (Placeholder)
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 24)
                                Text("Export Data")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding()
                            .liquidGlass()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - HELPERS & REUSED VIEWS

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title.uppercased())
                .font(.system(size: 10))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .liquidGlass()
    }
}

struct HeaderView: View {
    var userName: String
    var onProfileTap: () -> Void
    
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
            
            Button(action: onProfileTap) {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(userName.prefix(1).uppercased()) // Initials
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.white)
                    )
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

// --- (All other subviews like QuoteCard, EntryRow, EntryDetailView, BreathingSpaceView remain unchanged below) ---

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

struct BreathingSpaceView: View {
    @State private var breathe = false
    let quote: String
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
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
