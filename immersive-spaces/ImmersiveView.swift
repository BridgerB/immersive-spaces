//
//  ImmersiveView.swift
//  immersive-spaces
//
//  Created by bridger on 3/17/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }

            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.2),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            sphere.position = [0, 1.5, -2]
            content.add(sphere)
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
