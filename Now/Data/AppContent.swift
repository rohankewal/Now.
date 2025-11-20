//
//  AppContent.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import Foundation

// MARK: - CONTENT VIEW MODEL
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
