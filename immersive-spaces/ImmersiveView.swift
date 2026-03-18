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
    var scene: any SceneContent = MountainScene()

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
