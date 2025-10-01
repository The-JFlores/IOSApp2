//
//  ContentView.swift
//  IOSApp2
//
//  Created by Jose Flores on 2025-10-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Display a list of clues
            List(sampleClues) { clue in
                VStack(alignment: .leading) {
                    Text(clue.title)
                        .font(.headline) // Bold title for the location
                    Text(clue.hint)
                        .font(.subheadline) // Smaller font for the hint
                        .foregroundColor(.gray) // Make the hint visually distinct
                }
                .padding(.vertical, 4) // Add spacing between items
            }
            .navigationTitle("Scavenger Hunt") // Title for the main screen
        }
    }
}

#Preview {
    ContentView()
}
