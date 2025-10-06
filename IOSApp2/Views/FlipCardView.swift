// Views/FlipCardView.swift
// IOSApp2
// Created by Jose Flores on 2025-10-02.

import SwiftUI
import PhotosUI

struct FlipCardView: View {
    let clue: Clue
    var onPhotoTaken: ((UIImage) -> Void)? = nil   // Optional: callback to notify the view model
    
    @State private var flipped = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCamera = false

    var body: some View {
        ZStack {
            // Front of the card
            VStack(alignment: .leading, spacing: 6) {
                Text(clue.title)
                    .font(.headline)
                Text(clue.hint)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if clue.isFound {
                    Text("✅ Found")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
            .opacity(flipped ? 0 : 1)
            
            // Back of the card (rotated 180° internally so it doesn’t appear upside down)
            VStack(spacing: 10) {
                if let address = clue.address {
                    Text("📍 \(address)")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                if let website = clue.website, let url = URL(string: website) {
                    Link("🌐 Visit website", destination: url)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(10)
                } else {
                    VStack(spacing: 8) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("📁 Choose photo")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            showCamera = true
                        } label: {
                            Text("📸 Take photo")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .shadow(radius: 4)
            .opacity(flipped ? 1 : 0)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // <- Key correction
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.6), value: flipped)
        .onTapGesture {
            flipped.toggle()
        }
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    onPhotoTaken?(uiImage)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            PhotoCaptureView(sourceType: .camera) { image in
                selectedImage = image
                onPhotoTaken?(image)
            }
        }
    }
}

struct FlipCardView_Previews: PreviewProvider {
    static var previews: some View {
        FlipCardView(
            clue: Clue(
                title: "Café Central",
                hint: "Find the best espresso in town",
                lat: 43.25,
                lon: -79.88,
                address: "123 Main St",
                website: "https://example.com"
            ),
            onPhotoTaken: { _ in }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
