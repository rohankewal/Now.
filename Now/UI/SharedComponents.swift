//
//  SharedComponents.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI

// MARK: - REUSABLE UI COMPONENTS

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
