//
//  EditView.swift
//  BucketList
//
//  Created by Tarun on 30/06/26.
//

import SwiftUI

struct EditView: View {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) var dismiss
    var loaction: Location
    @State private var name: String
    @State private var description: String
    var onSave: (Location) -> Void
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    var body: some View {
        NavigationStack {
            Form {
                Section{
                    TextField("Place name",text: $name)
                    TextField("Place description", text: $description)
                }
                
                Section{
                    switch loadingState {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            HStack(spacing: 0) {
                                Text(page.title)
                                    .font(.headline)

                                Text(": ")

                                Text(page.description)
                                    .italic()
                            }
                        }
                    case .failed:
                        Text("Please try again.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = loaction
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    
                    onSave(newLocation)
                    
                    dismiss()
                }
            }
            .task {
                await fetchNearByPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void){
        self.loaction = location
        self.onSave = onSave
        _name = .init(initialValue: location.name)
        _description = .init(initialValue: location.description)
    }
    
    func fetchNearByPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(loaction.latitude)%7C\(loaction.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid url found \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode(Result.self, from: data)
            pages = items.query.pages.values.sorted() //pages is comparable
            loadingState = .loaded
            
        } catch {
            loadingState = .failed
            print("Error occured while loading \(error.localizedDescription)")
        }
    }
}

#Preview {
    EditView(location: .example) { _ in}
}
