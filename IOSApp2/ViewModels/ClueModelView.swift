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
class ClueModelView: ObservableObject {
    @Published var clues: [Clue] = []
    
    let geoapifyApiKey = "93948f25439b433b8c99ad1a9060396f"
    
    // To track which clue is selected for camera or other actions
    @Published var selectedClue: Clue?
    
    init() {
        Task {
            await fetchHamiltonPlaces()
        }
    }
    
    // MARK: - Fetch Hamilton places using Geoapify API
    func fetchHamiltonPlaces() async {
        let categories = "catering.restaurant,commercial.supermarket,entertainment.cinema,accommodation.hotel"
        let minLon = -79.95
        let minLat = 43.20
        let maxLon = -79.85
        let maxLat = 43.30
        
        let urlString = "https://api.geoapify.com/v2/places?categories=\(categories)&filter=rect:\(minLon),\(minLat),\(maxLon),\(maxLat)&limit=20&apiKey=\(geoapifyApiKey)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Malformed URL")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Status: \(httpResponse.statusCode)")
            }
            
            let decoded = try JSONDecoder().decode(GeoapifyResponse.self, from: data)
            
            // Map features to Clue objects with custom hints
            self.clues = decoded.features.map { feature in
                let props = feature.properties
                let title = props.name ?? "Unknown Place"
                var hint = "Explore this place and discover something interesting!"

                switch title {
                case "No Frills":
                    hint = "Grab fresh groceries at low prices."
                case "Fortinos":
                    hint = "A trusted local supermarket with great selection."
                case "Costco":
                    hint = "Find bulk deals and tasty food court snacks."
                case "Denninger's Foods of the World":
                    hint = "Taste foods from around the world in one spot."
                case "Bread Bar":
                    hint = "Try their famous pizzas and craft cocktails."
                case "Shakespeares":
                    hint = "Classic pub vibes with hearty meals and cold beer."
                case "Peruviano":
                    hint = "Enjoy authentic Peruvian cuisine and flavors."
                case "Tahini's":
                    hint = "Middle Eastern shawarma and bowls full of flavor."
                case "Mr. Gao":
                    hint = "Savor Chinese cuisine with generous portions."
                case "Em Oi":
                    hint = "Vietnamese comfort food served fresh daily."
                case "Electric Diner":
                    hint = "Retro diner serving brunch and classic milkshakes."
                case "B-Side Social":
                    hint = "Bar and grill with live music and great atmosphere."
                case "Dragon Court":
                    hint = "Chinese restaurant with dim sum and hot tea."
                case "Food Basics":
                    hint = "Affordable supermarket for your daily groceries."
                case "Strathcona Market":
                    hint = "A community market with fresh local produce."
                case "Nations Fresh Foods":
                    hint = "A huge supermarket offering global ingredients."
                case "Joya Sushi":
                    hint = "Japanese restaurant serving creative sushi rolls."
                case "Bean Bar":
                    hint = "Trendy café for coffee, desserts, and brunch."
                case "Eastern Food Market":
                    hint = "Shop for Asian groceries and specialty products."
                case "West Town Bar & Grill":
                    hint = "Neighborhood bar known for its comfort food."
                default:
                    hint = "Explore this local gem and see what you find!"
                }

                return Clue(
                    title: title,
                    hint: hint,
                    lat: props.lat,
                    lon: props.lon,
                    address: props.address_line1 ?? "No address available",
                    website: props.website
                )
            }
            
            print("✅ Loaded \(clues.count) Hamilton places")
        } catch {
            print("❌ Error fetching Hamilton places: \(error)")
        }
    }
    
    // MARK: - Game logic
    func markClueAsFound(clueID: UUID, image: UIImage?) {
        guard let index = clues.firstIndex(where: { $0.id == clueID }) else { return }
        clues[index].isFound = true
        if let img = image, let data = img.jpegData(compressionQuality: 0.8) {
            clues[index].userPhotoData = data
            clues[index].photoDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        }
    }
    
    func processPhotoForClue(clueID: UUID, image: UIImage, completion: @escaping () -> Void) {
        guard let index = clues.firstIndex(where: { $0.id == clueID }) else { completion(); return }
        if let data = image.jpegData(compressionQuality: 0.9) { clues[index].userPhotoData = data }
        clues[index].photoDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        completion()
    }
    
    // MARK: - Reward logic
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
    
    // MARK: - Camera & PDF Helpers
    func selectCamera(for clueID: UUID) {
        if let clue = clues.first(where: { $0.id == clueID }) {
            selectedClue = clue
        }
    }
    
    func generateMultiPDFReport(completion: @escaping (URL?) -> Void) {
        ReportGenerator.generateReport(for: clues, completion: completion)
    }
    
    func removePhoto(for clueID: UUID) {
        guard let index = clues.firstIndex(where: { $0.id == clueID }) else { return }
        clues[index].userPhotoData = nil
        clues[index].photoDate = nil
    }
}

// MARK: - Geoapify Models
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
