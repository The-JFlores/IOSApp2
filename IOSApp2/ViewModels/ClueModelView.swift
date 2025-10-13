//
//  ClueViewModel.swift
//  IOSApp2
//
//  Created by Jose Flores on 2025-10-05.
//

import Foundation
import UIKit
import CoreLocation

@MainActor
class ClueViewModel: ObservableObject {
    @Published var clues: [Clue] = []
    
    init() {
        Task {
            await fetchCluesFromGeoapify()
        }
    }
    
    // MARK: - Fetch places from Geoapify API
    func fetchCluesFromGeoapify() async {
        // Puedes cambiar "Oakville" por cualquier ciudad o coordenadas
        let latitude = 43.4453
        let longitude = -79.6989
        let apiKey = "8f43f0b72eb34de785b40c14e4a4ca4a"
        
        guard let url = URL(string:
            "https://api.geoapify.com/v2/places?categories=commercial.supermarket,entertainment.cinema,accommodation.hotel,catering.restaurant&filter=circle:\(longitude),\(latitude),3000&bias=proximity:\(longitude),\(latitude)&limit=10&apiKey=\(apiKey)"
        ) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(GeoapifyResponse.self, from: data)
            
            self.clues = decoded.features.map { feature in
                let props = feature.properties
                return Clue(
                    title: props.name ?? "Unknown Place",
                    hint: "Look for a place in category \(props.categories?.first ?? "N/A")",
                    lat: props.lat,
                    lon: props.lon,
                    address: props.address_line1 ?? "No address available",
                    website: props.website
                )
            }
            
            print("✅ Loaded \(clues.count) places from Geoapify")
        } catch {
            print("❌ Error fetching data: \(error)")
        }
    }
    
    // MARK: - Game logic
    func markClueAsFound(clueID: UUID, image: UIImage?) {
        guard let index = clues.firstIndex(where: { $0.id == clueID }) else { return }
        clues[index].isFound = true
        if let img = image, let data = img.jpegData(compressionQuality: 0.8) {
            clues[index].userPhotoData = data
        }
    }
    
    func imageForClue(_ clue: Clue) -> UIImage? {
        if let data = clue.userPhotoData { return UIImage(data: data) }
        return nil
    }

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
    
    func submitResults() {
        let rewardMessage = calculateReward()
        print("Submitting results... Reward: \(rewardMessage)")
    }
}

//
// MARK: - Geoapify API Models
//

struct GeoapifyResponse: Codable {
    let features: [GeoapifyFeature]
}

struct GeoapifyFeature: Codable {
    let properties: GeoapifyProperties
}

struct GeoapifyProperties: Codable {
    let name: String?
    let lat: Double
    let lon: Double
    let address_line1: String?
    let categories: [String]?
    let website: String?
}
