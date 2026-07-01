//
//  ContentView.swift
//  BucketList
//
//  Created by Tarun on 29/06/26.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct User:Comparable, Identifiable { // using comparable, we can compare and sort the items, we can do our custom sorting on any objects.just give sorted() for object that created, it will apply our custom sort. this is the isolated way to apply custom sort.
    let id = UUID()
    let firstName: String
    let secondName: String
    
    static func <(lhs: User, rhs: User) -> Bool {
        lhs.secondName < rhs.secondName
    }
}

//MARK: examples for enum cases
struct Loading: View {
    var body: some View {
        Text("Loading...")
    }
}

struct Success: View {
    var body: some View {
        Text("Success!")
    }
}

struct Failed: View {
    var body: some View {
        Text("Failed.")
    }
}

//Pointing locations
struct Locations: Identifiable {
    let id = UUID()
    var name: String
    var location: CLLocationCoordinate2D
}

struct ContentView: View {
    let users = [
        User(firstName: "Tarun", secondName: "Uggina"),
        User(firstName: "Christane", secondName: "Konanshiki"),
        User(firstName: "Krunoslav", secondName: "Kralj"),
    ].sorted()
    
    //using enum
//    enum LoadingState {
//        case loading, success, failed
//    }
    
//    @State private var loadingState = LoadingState.loading
    
    //MapKit varibles
    @State private var position = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 16.7107, longitude: 81.0952), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    
    //Pointing locations varibles
    let locations = [
        Locations(name: "Hyderabad",location: CLLocationCoordinate2D(latitude: 17.3850,longitude: 78.4867)),
            Locations(name: "Eluru",location: CLLocationCoordinate2D(latitude: 16.7107,longitude: 81.0952))
    ]
    
    //authentication varibles
    @State private var isUnlocked = false
    
    //Adding locations varaibles
    let startPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 16.7107, longitude: 81.0952), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    
    //VAriables moved to viewModel.
//    @State private var locationsToAdd = [Location]()
//    @State private var selectedPlace: Location?
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
//        List(users) { user in
//            Text(user.firstName)
//        }
        
        //MARK: App storing in document directory.
//        Button("Read and write") {
//            let data = Data("Test message".utf8)
//            let url = URL.documentsDirectory.appending(path: "message.txt")
//            
//            do{
//                try data.write(to: url, options: [.atomic, .completeFileProtection])
//                let input = try String(contentsOf: url,encoding: .utf8)
//                print(input)
//            }catch {
//                print(error.localizedDescription)
//            }
//        }
        
        //MARK: knowing How to utlise the enums, we can also use the switch tree.
//        if loadingState == .loading {
//            Loading()
//        }else if loadingState == .success {
//            Success()
//        }else if loadingState == .failed {
//            Failed()
//        }
        
        //MARK: Integrating MapKit in our app, boom.
//        Map(interactionModes: []) //we can provide the interaction modes also.
//            .mapStyle(.imagery)
//            .mapStyle(.hybrid(elevation:.realistic))
//        VStack{
//            Map(position: $position)
//                .mapStyle(.hybrid(elevation: .realistic))
//                .onMapCameraChange { context in
//                    print(context.region)
//                }
//            
//            Button("Paris") {
//                position = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)))
//            }
//            
//            Button("Tokyo") {
//                position = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.6897, longitude: 139.6922), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)))
//            }
//        }
        
        //MARK: Identifing locations,
//        VStack {
//            Map{
//                ForEach(locations) { location in
//                    Marker(location.name, coordinate: location.location) // we will get a 2 red ballons at the locations.
//                }
//            }
//        }
        
        //MARK: Using faceID to unloack the app.For we use LocalAuthentication
        //First go to targets -> Info -> Add a row -> privacy - FaceID -> Some text.
//        VStack{
//            if isUnlocked {
//                Text("Unlocked")
//            }else {
//                Text("Locked")
//            }
//        }
//        .onAppear(perform: authenticate)
        
        //MARK: Adding user locations to a map.
        if viewModel.unlocked {
            MapReader { proxy in
                Map(initialPosition: startPosition){
                    ForEach(viewModel.locationsToAdd) { location in
                        //                    Marker(location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                        Annotation(location.name, coordinate: location.coordinate){
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(.circle)
                                .gesture(
                                    LongPressGesture(minimumDuration: 0.2)
                                        .onEnded { _ in
                                            viewModel.selectedPlace = location
                                        }
                                )
                        }
                    }
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local){
                        viewModel.addLocation(at: coordinate)
                    }
                }
                .sheet(item: $viewModel.selectedPlace) { place in
                    EditView(location: place) {
                        viewModel.updateLocation(location: $0)
                    }
                }
            }
        } else {
            Button("Unlock places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "We need to unlock your data"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticateError in
                if success {
                    DispatchQueue.main.async(){
                        isUnlocked = true
                    }
                }else {
                    // Some error while authetication.
                }
            }
        }else {
            //No biometrics
        }
    }
}

#Preview {
    ContentView()
}
