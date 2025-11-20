//
//  Models.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import Foundation
import SwiftData

// MARK: - SWIFTDATA MODEL
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

// MARK: - API MODELS
struct APIQuote: Codable {
    let content: String
    let author: String
}
