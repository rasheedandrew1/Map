//
//  MapStyleConfig.swift
//  Map
//
//  Created by Rasheed on 10/2/24.
//

import SwiftUI
import MapKit

struct MapStyleConfig {
    
    enum BaseMapStyle: CaseIterable {
        case standard
        case hybrid
        case imagery
       
        var label: String {
            switch self {
            case .standard: return "Standard"
            case .hybrid: return "Hybrid"
            case .imagery: return "Imagery"
            }
        }
    }
    
    enum MapElevation {
        case flat, realistic
        
        var selection: MapStyle.Elevation {
            switch self {
            case .flat:
                return .flat
            case .realistic:
                return .realistic
            }
        }
    }
    
    enum MapPOI {
        case all, excludingAll
        var selection: PointOfInterestCategories {
            switch self {
            case .all:
                    .all
            case .excludingAll:
                    .excludingAll
            }
        }
    }
    
    var baseStyle = BaseMapStyle.standard
    var elevation = MapElevation.flat
    var pointOfInterest = MapPOI.excludingAll
    
    var showTraffic = false
    var mapStyle: MapStyle {
        switch baseStyle {
        case .standard:
            MapStyle.standard(elevation: elevation.selection, pointsOfInterest: pointOfInterest.selection, showsTraffic: showTraffic)
        case .hybrid:
            MapStyle.hybrid(elevation: elevation.selection, pointsOfInterest: pointOfInterest.selection, showsTraffic: showTraffic)
        case .imagery:
            MapStyle.imagery(elevation: elevation.selection)
        }
    }
}
