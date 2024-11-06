//
//  LocationDeniedView.swift
//  Map
//
//  Created by Rasheed on 9/30/24.
//

import SwiftUI

struct LocationDeniedView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Location Denied", systemImage: "location.off")
        } description: {
            Text("""
1. Tap the button below and go to "Privacy and Security"
2. Tap on "Location Services"
3. Locate the "Map" app and tap on it
4. Change the setting to "while using the App"
""")
            .multilineTextAlignment(.leading)
        } actions: {
            Button {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            } label: {
                Text("Open Settings")
            }
            .buttonStyle(.borderedProminent)
        }

    }
}

#Preview {
    LocationDeniedView()
}
