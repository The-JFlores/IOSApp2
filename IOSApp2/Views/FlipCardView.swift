//
//  FlipCardView.swift
//  IOSApp2
//

import SwiftUI
import PhotosUI
import MapKit

struct FlipCardView: View {
    @Binding var clue: Clue
    @EnvironmentObject var vm: ClueModelView

    @State private var isFlipped = false
    @State private var showCamera = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
            back
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(Color.clear)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlipped.toggle()
            }
        }
    }

    // MARK: - Front View
    private var front: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(clue.title)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(clue.hint)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
            
            if let photoDate = clue.photoDate {
                Text("📅 \(photoDate)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x:0,y:1,z:0))
    }

    // MARK: - Back View
    private var back: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 12) {
                if let data = clue.userPhotoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                Spacer()
            }

            if let address = clue.address {
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }

            Text(clue.hint)
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))

            if let photoDate = clue.photoDate {
                Text("📅 \(photoDate)")
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            HStack(spacing: 8) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("📁 Choose photo")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .onChange(of: selectedPhoto) { newPhoto in
                    Task {
                        if let data = try? await newPhoto?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            vm.markClueAsFound(clueID: clue.id, image: uiImage)
                        }
                    }
                }

                Button("📸 Take photo") {
                    showCamera = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .sheet(isPresented: $showCamera) {
                    PhotoCaptureView(sourceType: .camera) { image in
                        selectedImage = image
                        vm.markClueAsFound(clueID: clue.id, image: image)
                    }
                }

                if clue.userPhotoData != nil {
                    Button("❌ Remove photo") {
                        vm.removePhoto(for: clue.id)
                        selectedImage = nil
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x:0,y:1,z:0))
    }
}
