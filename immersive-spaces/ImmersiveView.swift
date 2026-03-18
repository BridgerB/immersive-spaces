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
    // var scene: any SceneContent = BigSur()
    // var scene: any SceneContent = Mountain()
    // var scene: any SceneContent = RainbowAssortment()
    // var scene: any SceneContent = TimesSquare()
    var scene: any SceneContent = ISS()

    var body: some View {
        RealityView { content in
await scene.build(content: &content)
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
