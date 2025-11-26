//
//  BreathingSpaceView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI

// MARK: - BREATHING MODELS
enum BreathingPattern: String, CaseIterable {
    case coherence = "Coherence" // Balanced: 5 in, 5 out
    case relax = "4-7-8 Relax"   // Anxiety: 4 in, 7 hold, 8 out
    case focus = "Box Focus"     // Focus: 4 in, 4 hold, 4 out, 4 hold
    
    var description: String {
        switch self {
        case .coherence: return "Balance your nervous system."
        case .relax: return "Deep calm and anxiety relief."
        case .focus: return "Heightened concentration."
        }
    }
}

struct BreathingSpaceView: View {
    // Configuration
    @State private var selectedPattern: BreathingPattern = .coherence
    @State private var isHapticsEnabled: Bool = true
    @State private var showSettings = false
    
    // Animation State
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5
    @State private var instruction: String = "Ready..."
    @State private var timer: Timer?
    @State private var phaseCount = 0
    
    let quote: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            // Main Breathing Circle
            ZStack {
                // Outer Glow
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: currentStepDuration), value: scale)
                
                // Inner Core
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale * 0.8)
                    .overlay(
                        Text(instruction)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .transaction { transaction in
                                transaction.animation = nil // Disable text fade animation
                            }
                    )
            }
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Quote Area
                VStack(spacing: 16) {
                    Text(quote)
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 40)
                    
                    Text(selectedPattern.rawValue.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 20)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear { startBreathing() }
        .onDisappear { stopBreathing() }
        .sheet(isPresented: $showSettings) {
            BreathingSettingsSheet(
                selectedPattern: $selectedPattern,
                isHapticsEnabled: $isHapticsEnabled,
                onUpdate: restartBreathing
            )
            .presentationDetents([.height(350)])
            .presentationBackground(.ultraThinMaterial)
        }
    }
    
    // MARK: - BREATHING LOGIC
    
    var currentStepDuration: Double {
        switch selectedPattern {
        case .coherence: return 5.0 // Uniform 5s
        case .relax:
            // This is complex for a simple view loop, simplifying visual for V1:
            // We will use an average visual pace but text updates correctly
            return 6.0
        case .focus: return 4.0
        }
    }
    
    func startBreathing() {
        stopBreathing()
        
        // Run the loop based on the pattern
        switch selectedPattern {
        case .coherence: runCoherenceLoop()
        case .focus: runBoxLoop()
        case .relax: runRelaxLoop()
        }
    }
    
    func restartBreathing() {
        stopBreathing()
        // Small delay to reset UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startBreathing()
        }
    }
    
    func stopBreathing() {
        timer?.invalidate()
        timer = nil
        scale = 1.0
        instruction = "Ready..."
    }
    
    func performHaptic() {
        if isHapticsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    // --- PATTERN LOOPS ---
    
    func runCoherenceLoop() {
        // 5s In, 5s Out
        let _cycle = 10.0
        
        // Initial State
        withAnimation(.easeInOut(duration: 5)) { scale = 1.5 }
        instruction = "Inhale"
        performHaptic()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { t in
            phaseCount += 1
            let isInhale = phaseCount % 2 == 0
            
            instruction = isInhale ? "Inhale" : "Exhale"
            performHaptic()
            
            withAnimation(.easeInOut(duration: 5)) {
                scale = isInhale ? 1.5 : 1.0
            }
        }
    }
    
    func runBoxLoop() {
        // 4 In, 4 Hold, 4 Out, 4 Hold
        var phase = 0 // 0: In, 1: Hold, 2: Out, 3: Hold
        
        let step = 4.0
        
        // Initial
        withAnimation(.linear(duration: step)) { scale = 1.5 }
        instruction = "Inhale"
        performHaptic()
        
        timer = Timer.scheduledTimer(withTimeInterval: step, repeats: true) { t in
            phase = (phase + 1) % 4
            performHaptic()
            
            switch phase {
            case 0: // Inhale
                instruction = "Inhale"
                withAnimation(.linear(duration: step)) { scale = 1.5 }
            case 1: // Hold
                instruction = "Hold"
            case 2: // Exhale
                instruction = "Exhale"
                withAnimation(.linear(duration: step)) { scale = 1.0 }
            case 3: // Hold
                instruction = "Hold"
            default: break
            }
        }
    }
    
    func runRelaxLoop() {
        // 4 In, 7 Hold, 8 Out
        // Approximating logic for simplicity in Timer
        // We define a total cycle function that calls itself
        
        func cycle() {
            // 1. Inhale (4s)
            instruction = "Inhale"
            performHaptic()
            withAnimation(.easeOut(duration: 4)) { scale = 1.5 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                guard self.timer != nil else { return }
                
                // 2. Hold (7s)
                self.instruction = "Hold"
                self.performHaptic()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    guard self.timer != nil else { return }
                    
                    // 3. Exhale (8s)
                    self.instruction = "Exhale"
                    self.performHaptic()
                    withAnimation(.easeIn(duration: 8)) { scale = 1.0 }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        guard self.timer != nil else { return }
                        cycle() // Loop
                    }
                }
            }
        }
        
        // We use the timer just as a "is active" flag here
        timer = Timer(timeInterval: 1000, repeats: false, block: { _ in })
        cycle()
    }
}

// MARK: - SETTINGS SHEET
struct BreathingSettingsSheet: View {
    @Binding var selectedPattern: BreathingPattern
    @Binding var isHapticsEnabled: Bool
    var onUpdate: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Breathing Settings")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Pattern Selector
            VStack(alignment: .leading, spacing: 12) {
                Text("PATTERN")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                            Button(action: {
                                selectedPattern = pattern
                                onUpdate()
                            }) {
                                VStack(alignment: .leading) {
                                    Text(pattern.rawValue)
                                        .fontWeight(.bold)
                                    Text(pattern.description)
                                        .font(.caption2)
                                        .opacity(0.8)
                                        .lineLimit(2)
                                }
                                .frame(width: 140, height: 80)
                                .padding()
                                .background(selectedPattern == pattern ? Color.white : Color.black.opacity(0.2))
                                .foregroundColor(selectedPattern == pattern ? .black : .white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Haptics Toggle
            Toggle(isOn: $isHapticsEnabled) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text("Haptic Vibrations")
                }
                .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
