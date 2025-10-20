//
//  File.swift
//  IOSApp2
//
//  Created by Jose Flores on 2025-10-15.
//
import Foundation
import UIKit
import MapKit
import PDFKit

class ReportGenerator {

    static func generateReport(for clues: [Clue], completion: @escaping (URL?) -> Void) {
        // Filtra solo los encontrados
        let foundClues = clues.filter { $0.isFound }
        guard !foundClues.isEmpty else { completion(nil); return }

        DispatchQueue.global(qos: .userInitiated).async {
            let pdfMetaData = [
                kCGPDFContextCreator: "Scavenger Hunt App",
                kCGPDFContextAuthor: "Jose Flores",
                kCGPDFContextTitle: "Clues Report"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]

            let fileName = "ScavengerHunt_Report.pdf"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            let pageWidth: CGFloat = 612
            let pageHeight: CGFloat = 792
            let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

            do {
                try renderer.writePDF(to: fileURL) { context in
                    // Dividir los clues en lotes de 3
                    let chunks = stride(from: 0, to: foundClues.count, by: 3).map {
                        Array(foundClues[$0..<min($0 + 3, foundClues.count)])
                    }

                    for chunk in chunks {
                        context.beginPage()
                        var y: CGFloat = 40
                        for clue in chunk {
                            // Título
                            let title = "📍 \(clue.title)"
                            title.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 20)])

                            y += 25

                            // Dirección
                            let address = clue.address ?? "No address"
                            address.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])

                            y += 20

                            // Fecha
                            let date = "📅 \(clue.photoDate ?? "Unknown")"
                            date.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])

                            y += 20

                            // Foto
                            if let data = clue.userPhotoData, let image = UIImage(data: data) {
                                let imgRect = CGRect(x: 40, y: y, width: 150, height: 150)
                                image.draw(in: imgRect)
                            }

                            // Mini mapa
                            let mapRect = CGRect(x: 220, y: y, width: 150, height: 150)
                            let location = CLLocationCoordinate2D(latitude: clue.lat, longitude: clue.lon)
                            let options = MKMapSnapshotter.Options()
                            options.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            options.size = CGSize(width: 150, height: 150)
                            options.scale = UIScreen.main.scale
                            let snapshotter = MKMapSnapshotter(options: options)
                            let semaphore = DispatchSemaphore(value: 0)
                            var snapshotImage: UIImage? = nil
                            snapshotter.start { snapshot, _ in
                                snapshotImage = snapshot?.image
                                semaphore.signal()
                            }
                            semaphore.wait()
                            if let mapImg = snapshotImage {
                                mapImg.draw(in: mapRect)
                            }

                            y += 160 // espacio entre clues
                        }
                    }
                }
                DispatchQueue.main.async { completion(fileURL) }
            } catch {
                print("❌ PDF generation error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
