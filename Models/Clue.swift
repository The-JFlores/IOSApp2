//
//  Clue.swift
//  IOSApp2
//
//  Created by Jose Flores on 2025-10-01.
//
import Foundation

/// Represents a clue/item in the scavenger hunt
struct Clue: Identifiable {
    let id: Int       // Unique identifier for each clue
    let title: String // Name of the location or business
    let hint: String  // Hint to help the user find the item
}
