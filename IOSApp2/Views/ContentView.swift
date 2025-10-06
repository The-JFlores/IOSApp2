//
//  ContentView.swift
//  IOSApp2
//
//  Created by Jose Flores on 2025-10-01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ClueViewModel()
    @State private var showRewardAlert = false
    @State private var rewardMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.clues) { clue in
                        FlipCardView(clue: clue) { image in
                            vm.markClueAsFound(clueID: clue.id, image: image)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button("Submit Results") {
                        rewardMessage = vm.calculateReward()
                        showRewardAlert = true
                        vm.submitResults()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Scavenger Hunt")
            .refreshable { vm.loadSampleData() }
            .alert(rewardMessage, isPresented: $showRewardAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

#Preview {
    ContentView()
}
