//
//  LocationDetailView.swift
//  Map
//
//  Created by Rasheed on 9/29/24.
//

import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    var destination: Destination?
    var selectedPlacemark: MTPlacemark?
    @Binding var showRoute: Bool
    @Binding var travelInterval: TimeInterval?
    @Binding var transportType : MKDirectionsTransportType
    
    var travelTime: String? {
        guard let travelInterval else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: travelInterval)
    }
    
    @State private var name = ""
    @State private var address = ""
    
    @State private var lookAroundScene: MKLookAroundScene?
    
    var isChanged: Bool {
        guard let selectedPlacemark else { return false }
        return (name != selectedPlacemark.name || address != selectedPlacemark.address)
    }
    
   var body: some View {
       VStack {
           HStack {
               VStack(alignment: .leading) {
                   if destination != nil {
                       TextField("Name", text: $name)
                           .font(.title)
                       TextField("address", text: $address, axis: .vertical)
                       if isChanged {
                           Button("Update") {
                               selectedPlacemark?.name = name
                                   .trimmingCharacters(in: .whitespacesAndNewlines)
                               selectedPlacemark?.address = address
                                   .trimmingCharacters(in: .whitespacesAndNewlines)
                           }
                           .frame(maxWidth: .infinity, alignment: .trailing)
                           .buttonStyle(.borderedProminent)
                       }
                   } else {
                       Text(selectedPlacemark?.name ?? "")
                           .font(.title)
                           .fontWeight(.semibold)
                       Text(selectedPlacemark?.address ?? "")
                           .font(.footnote)
                           .foregroundStyle(.secondary)
                           .lineLimit(2)
                           .fixedSize(horizontal: false, vertical: true)
                           .padding(.trailing)
                   }
                   
                   if destination == nil {
                       HStack {
                           
                           Button {
                               transportType = .automobile
                           } label: {
                               Image(systemName: "car")
                                   .symbolVariant(transportType == .automobile ? .circle : .none)
                                   .imageScale(.large)
                           }
                           
                           Button {
                               transportType = .walking
                           } label: {
                               Image(systemName: "figure.walk")
                                   .symbolVariant(transportType == .walking ? .circle : .none)
                                   .imageScale(.large)
                           }
                           
                        
                           
                           if let travelTime {
                               let prefixe = transportType == .automobile ? "Driving" : "Walking"
                               Text("\(prefixe) time: \(travelTime)")
                                   .font(.caption)
                                   .foregroundStyle(.secondary)
                           }
                       }
                   }
               }
               .textFieldStyle(.roundedBorder)
               .autocorrectionDisabled()
               Spacer()
               Button {
                   dismiss()
               } label: {
                   Image(systemName: "xmark.circle.fill")
                       .imageScale(.large)
                       .foregroundStyle(.gray)
               }
           }
           
           if let lookAroundScene {
               LookAroundPreview(initialScene: lookAroundScene)
                   .frame(height: 200)
                   .padding()
           } else {
               ContentUnavailableView("No preview available", systemImage: "eye.slash")
           }
           
           
           HStack {
               Spacer()
               if let destination {
                   let inList = (selectedPlacemark != nil &&
                                 selectedPlacemark?.destination != nil)
                   Button {
                       
                       if let selectedPlacemark {
                           if selectedPlacemark.destination == nil {
                               destination.placemarks.append(selectedPlacemark)
                           } else {
                               selectedPlacemark.destination = nil
                           }
                           dismiss()
                       }
                       
                   } label: {
                       Label(inList ? "Remove" : "Add", systemImage: inList ? "minus.circle" : "plus.circle")
                   }
                   .buttonStyle(.borderedProminent)
                   .tint(inList ? .red : .green)
                   .disabled((name.isEmpty || isChanged))
               } else {
                   HStack {
                       Button("Open in maps", systemImage: "map") {
                           if let selectedPlacemark {
                               let placemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
                               let mapItem = MKMapItem(placemark: placemark)
                               mapItem.name = selectedPlacemark.name
                               mapItem.openInMaps()
                           }
                       }
                       .fixedSize(horizontal: true, vertical: false)
                       Button("Show Route", systemImage: "location.north") {
                           showRoute.toggle()
                       }
                       .fixedSize(horizontal: true, vertical: false)
                   }
                   .buttonStyle(.bordered)

               }
           }
           Spacer()
       }
       .padding()
       .task(id: selectedPlacemark) {
           await fetchLookAroundPreview()
       }
           .onAppear {
               if let selectedPlacemark, destination != nil {
                   name = selectedPlacemark.name
                   address = selectedPlacemark.address
               }
           }
    }
    
    func fetchLookAroundPreview() async {
        if let selectedPlacemark {
            lookAroundScene = nil
            let lookAroundRequest = MKLookAroundSceneRequest(
                coordinate: selectedPlacemark.coordinate)
            lookAroundScene = try? await lookAroundRequest.scene
        }
    }
    
    
}


#Preview("Destination Tab") {

    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    let selectedPlacemark = destination.placemarks[0]
    return LocationDetailView(
        destination: destination,
        selectedPlacemark: selectedPlacemark,
        showRoute: .constant(false),
        travelInterval: .constant(nil),
        transportType: .constant(.automobile)
    )
}


#Preview("TripMap Tab") {

    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<MTPlacemark>()
    let placemarks = try! container.mainContext.fetch(fetchDescriptor)
    let selectedPlacemark = placemarks[0]
    return LocationDetailView(
        selectedPlacemark: selectedPlacemark,
        showRoute: .constant(false),
        travelInterval: .constant(TimeInterval(1000)),
        transportType: .constant(.automobile)
    )
}
