//
//  ThemeManager.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? Theme.dark.rawValue
        self.currentTheme = Theme(rawValue: savedTheme) ?? .dark
    }
    
    // MindSpark Color Palette
    static let primaryBackground = Color(hex: "5D0105") // Deep red background
    static let accentYellow = Color(hex: "F6E321") // Bright yellow
    static let accentBlue = Color(hex: "1888FF") // Bright blue
    
    static let cardBackground = Color(hex: "1C1C1E")
    static let secondaryBackground = Color(hex: "2C2C2E")
    static let tertiaryBackground = Color(hex: "3A3A3C")
    
    var backgroundColor: Color {
        currentTheme == .dark ? ThemeManager.primaryBackground : Color(hex: "F5F5F7")
    }
    
    var cardColor: Color {
        currentTheme == .dark ? ThemeManager.cardBackground : .white
    }
    
    var textPrimary: Color {
        currentTheme == .dark ? .white : Color(hex: "1C1C1E")
    }
    
    var textSecondary: Color {
        currentTheme == .dark ? Color(hex: "EBEBF5").opacity(0.6) : Color(hex: "3C3C43").opacity(0.6)
    }
}

enum Theme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    
    var displayName: String {
        rawValue
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
