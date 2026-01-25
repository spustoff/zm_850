//
//  SettingsView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingResetAlert = false
    @State private var username: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    HStack {
                        Text("Username")
                        Spacer()
                        TextField("Username", text: $username)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(themeManager.textSecondary)
                    }
                } header: {
                    Text("Profile")
                }
                
                // Appearance Section
                Section {
                    Picker("Theme", selection: Binding(
                        get: { themeManager.currentTheme },
                        set: { themeManager.currentTheme = $0 }
                    )) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                // Preferences Section
                Section {
                    Picker("Default Difficulty", selection: $appState.userProfile.preferences.preferredDifficulty) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    
                    Toggle("Sound Effects", isOn: $appState.userProfile.preferences.soundEnabled)
                    
                    Toggle("Haptic Feedback", isOn: $appState.userProfile.preferences.hapticEnabled)
                    
                    Toggle("Notifications", isOn: $appState.userProfile.preferences.enableNotifications)
                } header: {
                    Text("Preferences")
                }
                
                // Categories Section
                Section {
                    NavigationLink(destination: CategoryPreferencesView()) {
                        HStack {
                            Text("Favorite Topics")
                            Spacer()
                            Text("\(appState.userProfile.preferences.selectedCategories.count)")
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }
                } header: {
                    Text("Learning")
                }
                
                // Data Section
                Section {
                    Button(role: .destructive, action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Data")
                        }
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("This will delete all your progress, statistics, and preferences. This action cannot be undone.")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(themeManager.textSecondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2026.01.25")
                            .foregroundColor(themeManager.textSecondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Save username if changed
                        if !username.isEmpty && username != appState.userProfile.username {
                            appState.userProfile.username = username
                        }
                        appState.saveProfile()
                        dismiss()
                    }
                }
            }
            .onAppear {
                username = appState.userProfile.username
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    appState.resetApp()
                    dismiss()
                }
            } message: {
                Text("This will permanently delete all your progress, statistics, and preferences. This action cannot be undone.")
            }
        }
    }
}

struct CategoryPreferencesView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedCategories: Set<QuizCategory> = []
    
    var body: some View {
        Form {
            Section {
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    Button(action: {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(selectedCategories.contains(category) ? ThemeManager.accentYellow : themeManager.textSecondary)
                                .frame(width: 30)
                            
                            Text(category.rawValue)
                                .foregroundColor(themeManager.textPrimary)
                            
                            Spacer()
                            
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(ThemeManager.accentYellow)
                            }
                        }
                    }
                }
            } header: {
                Text("Select Your Favorite Topics")
            } footer: {
                Text("You'll see more content from these categories")
            }
        }
        .navigationTitle("Favorite Topics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedCategories = Set(appState.userProfile.preferences.selectedCategories)
        }
        .onDisappear {
            appState.userProfile.preferences.selectedCategories = Array(selectedCategories)
            appState.saveProfile()
        }
    }
}
