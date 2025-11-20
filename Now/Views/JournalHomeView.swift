//
//  JournalHomeView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI
import SwiftData

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
