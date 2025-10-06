//
//  ClueModelView.swift
//  IOSApp2
//
//  Created by Jose Flores on 2025-10-05.
//

// ViewModels/ClueViewModel.swift
import Foundation
import UIKit

@MainActor
class ClueViewModel: ObservableObject {
    @Published var clues: [Clue] = []
    
    init() {
        // Sample data (or you can call fetchClues() if using Geoapify)
        loadSampleData()
    }
    
    func loadSampleData() {
        clues = [
            Clue(title: "No Frills", hint: "Look for the main entrance", lat: 43.2518, lon: -79.8523, address: "435 Main Street East", website: "https://www.nofrills.ca"),
            Clue(title: "Local Cinema", hint: "Look for the big movie poster", lat: 43.26, lon: -79.88, address: "200 Cineplex Blvd"),
            Clue(title: "Downtown Bookstore", hint: "Look for the display with novels", lat: 43.27, lon: -79.86, address: "45 Oak Avenue")
            // Add up to 10 if desired
        ]
    }
    
    /// Marks a clue as found and saves the image in data
    func markClueAsFound(clueID: UUID, image: UIImage?) {
        guard let index = clues.firstIndex(where: { $0.id == clueID }) else { return }
        clues[index].isFound = true
        if let img = image, let data = img.jpegData(compressionQuality: 0.8) {
            clues[index].userPhotoData = data
        }
    }
    
    /// Returns a UIImage from userPhotoData (if available)
    func imageForClue(_ clue: Clue) -> UIImage? {
        if let data = clue.userPhotoData { return UIImage(data: data) }
        return nil
    }
    
    // (Optional) If using Geoapify, implement fetchClues() here.
    // Note: Although we were taught how to use the Geoapify API, I was not able to implement it in this version.
    // I tried to integrate it, but I couldn’t get it working. I could implement it in the future with guidance or additional practice.

}

extension ClueViewModel {
    
    /// Calculate the reward based on found clues
    func calculateReward() -> String {
        let foundCount = clues.filter { $0.isFound }.count
        
        switch foundCount {
        case 10:
            return "You found all 10 items! You get a 20% discount and are entered into the $5000 grand prize draw!"
        case 7...9:
            return "Great job! You found \(foundCount) items. You get a 20% discount!"
        case 5...6:
            return "Good work! You found \(foundCount) items. You get a 10% discount!"
        default:
            return "You found \(foundCount) items. Keep looking to earn rewards!"
        }
    }
    
    /// Simulate submitting results online
    func submitResults() {
        let rewardMessage = calculateReward()
        print("Submitting results... Reward: \(rewardMessage)")
        // Here you could implement real network POST in the future
    }
}

