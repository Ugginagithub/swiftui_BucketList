//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Tarun on 01/07/26.
//

import CoreLocation
import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    
    @Observable
    class ViewModel {
        private(set) var locationsToAdd = [Location]()
        var selectedPlace: Location?
        var unlocked = false
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locationsToAdd = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locationsToAdd = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locationsToAdd)
                try data.write(to: savePath)
            } catch {
                print("Unable to save the data.")
            }
        }
        
        func addLocation(at point: CLLocationCoordinate2D){
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: point.latitude, longitude: point.longitude)
            
            locationsToAdd.append(newLocation)
            save()
        }
        
        func updateLocation(location: Location){
            guard let selectedPlace else { return }
            
            if let index = locationsToAdd.firstIndex(of: selectedPlace){
                locationsToAdd[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){
                    success, authenticatoinError in
                    if success {
                        self.unlocked = true
                    } else {
                        //error
                    }
                }
            } else{
                // no biometerics
            }
        }
    }
}
