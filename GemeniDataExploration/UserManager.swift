//
//  UserManager.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import Foundation
import SwiftData

@MainActor
final class UserManager {
    /// Ensures a UserProfile exists in SwiftData, creating a default one if needed.
    static func ensureUserProfileExists(in context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            let existingProfiles = try context.fetch(descriptor)
            if existingProfiles.isEmpty {
                let defaultProfile = UserProfile(startingBankroll: 1000.00)
                context.insert(defaultProfile)
                try context.save()
            }
        } catch {
            print("Failed to fetch or create UserProfile: \(error)")
        }
    }
}
