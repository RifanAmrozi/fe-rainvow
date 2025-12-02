//
//  FilterViewModel.swift
//  Octrum
//
//  Created on 24/11/25.
//

import Foundation
import Combine

class FilterViewModel: ObservableObject {
    @Published var aisleLocations: [String] = []
    @Published var selectedAisleLocation: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let filterService = FilterService.shared
    
    func fetchAisleLocations(storeId: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let locations = try await filterService.fetchAisleLocations(storeId: storeId)
                
                await MainActor.run {
                    self.aisleLocations = locations
                    self.isLoading = false
                    print("✅ Loaded \(locations.count) aisle locations")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load locations: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ Error fetching aisle locations: \(error)")
                }
            }
        }
    }
    
    func applyFilter() -> String? {
        return selectedAisleLocation
    }
    
    func resetFilter() {
        selectedAisleLocation = nil
    }
}
