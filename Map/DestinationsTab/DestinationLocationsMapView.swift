//
//  DestinationLocationMapView.swift
//  Map
//
//  Created by Rasheed on 9/29/24.
//

import SwiftUI
import MapKit
import SwiftData

struct DestinationLocationsMapView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText = ""
    @FocusState private var searchFieldFocus: Bool
    @Query(filter: #Predicate<MTPlacemark> {$0.destination == nil}) private var searchPlacemarks: [MTPlacemark]
    private var listPlacemarks: [MTPlacemark] {
        searchPlacemarks + destination.placemarks
    }
    var destination: Destination
    @State private var isManualMarker = false
    
    @State private var selectedPlacemark: MTPlacemark?
    var body: some View {
        @Bindable var destination = destination
        VStack {
            LabeledContent {
                TextField("Enter destination name", text: $destination.name)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.primary)
            } label: {
                Text("Name")
            }
            HStack {
                Text("Adjust the map to set the region for your destination.")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Set region") {
                    if let visibleRegion {
                        destination.latitude = visibleRegion.center.latitude
                        destination.longitude = visibleRegion.center.longitude
                        destination.latitudeDelta = visibleRegion.span.latitudeDelta
                        destination.longitudeDelta = visibleRegion.span.longitudeDelta
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal)
        MapReader { proxy in
            Map(position: $cameraPosition, selection: $selectedPlacemark) {
                ForEach(listPlacemarks) { placemark in
                    if isManualMarker {
                        if placemark.destination != nil {
                            Marker(coordinate: placemark.coordinate) {
                                Label(placemark.name, systemImage: "star")
                            }
                            .tint(.yellow)
                        } else {
                            Marker(placemark.name, coordinate: placemark.coordinate)
                        }
                    } else {
                        Group {
                            if placemark.destination != nil {
                                Marker(coordinate: placemark.coordinate) {
                                    Label(placemark.name, systemImage: "star")
                                }
                                .tint(.yellow)
                            } else {
                                Marker(placemark.name, coordinate: placemark.coordinate)
                            }
                        }.tag(placemark)
                    }
                }
            }
            .onTapGesture { position in
                if isManualMarker {
                    if let coordinate = proxy.convert(position, from: .local) {
                        let mtPlacemark = MTPlacemark(
                            name: "",
                            address: "",
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        )
                        modelContext.insert(mtPlacemark)
                        selectedPlacemark = mtPlacemark
                    }
                }
            }
        }
        .sheet(item: $selectedPlacemark, onDismiss: {
            if isManualMarker {
                MapManager.removeSearchResults(modelContext)
            }
        }) { selectedPlacemark in
            LocationDetailView(
                destination: destination,
                selectedPlacemark: selectedPlacemark, showRoute: .constant(false),
                travelInterval: .constant(nil),
                transportType: .constant(.automobile)
            )
                .presentationDetents([.height(450)])
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Toggle(isOn: $isManualMarker) {
                    Label("Tap marker placement is: \(isManualMarker ? "ON" : "OFF")", systemImage: isManualMarker ? "mappin.circle" : "mappin.slash.circle")
                }
                .fontWeight(.bold)
                .toggleStyle(.button)
                .background(.ultraThinMaterial)
                .onChange(of: isManualMarker) {
                    MapManager.removeSearchResults(modelContext)
                }
                if !isManualMarker{
                    HStack {
                        TextField("Search...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($searchFieldFocus)
                            .overlay(alignment: .trailing) {
                                if searchFieldFocus {
                                    Button {
                                        searchText = ""
                                        searchFieldFocus = false
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                    .offset(x: -5)
                                }
                            }
                            .onSubmit {
                                Task {
                                    await MapManager.searchPlaces(
                                        modelContext,
                                        searchText: searchText,
                                        visibleRegion: visibleRegion
                                    )
                                    searchText = ""
                                    cameraPosition = .automatic
                                }
                            }
                        if !searchPlacemarks.isEmpty {
                            Button {
                                MapManager.removeSearchResults(modelContext)
                            }label: {
                                Image(systemName: "mappin.slash.circle.fill")
                                    .imageScale(.large)
                            }
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.red)
                            .clipShape(.circle)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Destination")
        .navigationBarTitleDisplayMode(.inline)
        .onMapCameraChange(frequency: .onEnd){ context in
            visibleRegion = context.region
        }
        .onAppear {
            MapManager.removeSearchResults(modelContext)
            if let region = destination.region {
                cameraPosition = .region(region)
            }
        }
        .onDisappear {
            MapManager.removeSearchResults(modelContext)
        }
    }
}

#Preview {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    return NavigationStack {
        DestinationLocationsMapView(destination: destination)
    }
    .modelContainer(Destination.preview)
}


//            Marker("Moulin Rouge", coordinate: CLLocationCoordinate2D(latitude: 48.884134, longitude: 2.332196))
//            
//            Marker("Moulin Rouge", coordinate: .moulinRouge)
//            
//            Marker(coordinate: .arcDeTriomphe) {
//                Label("Arc de Tromphe", image: "star.fill")
//            }.tint(.yellow)
//            
//            Marker("Eiffel Tower", image: "eiffelTower", coordinate: .eiffelTower)
//                .tint(.blue)
//            
//            Marker("Gare du Nord", monogram: Text("GN"), coordinate: .gareDuNord)
//                .tint(.accent)
//            
//            Marker("Louvre", systemImage: "person.crop.artframe", coordinate: .louvre)
//                .tint(.appBlue)
//            
//            Annotation("Notre Dame", coordinate: .notreDame) {
//                Image(systemName: "star")
//                    .imageScale(.large)
//                    .foregroundStyle(.red)
//                    .padding(10)
//                    .background(.white)
//                    .clipShape(.circle)
//            }
//            
//            Annotation("Sacré Coeur",coordinate: .sacreCoeur, anchor: .center) {
//                Image(.sacreCoeur)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//            }
//            
//            Annotation("Pantheon", coordinate: .pantheon) {
//                Image(systemName: "mappin")
//                    .imageScale(.large)
//                    .foregroundStyle(.red)
//                    .padding(5)
//                    .overlay {
//                        Circle()
//                            .strokeBorder(.red, lineWidth: 2)
//                    }
//            }
//            
//            MapCircle(center: .pantheon, radius: 5000)
//                .foregroundStyle(.red.opacity(0.5))
