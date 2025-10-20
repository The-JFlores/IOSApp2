//
//  ContentView.swift
//  IOSApp2
//
//  Created by Jose Flores on 2025-10-01.
//

import SwiftUI
import MapKit
import PhotosUI

struct ContentView: View {
    @StateObject private var vm = ClueModelView()
    @State private var showRewardAlert = false
    @State private var rewardMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach($vm.clues) { $clue in
                        FlipCardView(clue: $clue)
                            .environmentObject(vm) // <- se pasa el EnvironmentObject aquí
                    }

                    ActionButtons(vm: vm,
                                  rewardMessage: $rewardMessage,
                                  showRewardAlert: $showRewardAlert)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Hamilton Scavenger Hunt")
            .refreshable {
                await vm.fetchHamiltonPlaces()
            }
            .alert(rewardMessage, isPresented: $showRewardAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .environmentObject(vm) // <- o también puedes pasarlo a todo ContentView
    }
}

// Action Buttons
struct ActionButtons: View {
    @ObservedObject var vm: ClueModelView
    @Binding var rewardMessage: String
    @Binding var showRewardAlert: Bool

    var body: some View {
        VStack(spacing: 12) {
            Button("Submit Results") {
                rewardMessage = vm.calculateReward()
                showRewardAlert = true
                vm.submitResults()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)

            Button("📄 Generate PDF Report") {
                vm.generateMultiPDFReport { url in
                    guard let url = url else { return }
                    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(activityVC, animated: true)
                    }
                }
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.vertical)
    }
}

#Preview {
    ContentView()
}
