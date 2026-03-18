//
//  RainbowAssortmentScene.swift
//  immersive-spaces
//

import RealityKit
import UIKit

struct RainbowAssortmentScene: SceneContent {
    func build(content: inout RealityViewContent) async {
        let colors: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .systemPink]
        let positions: [(Float, Float, Float)] = [
            (-2.5, 1.2, -3.0), ( 2.0, 2.0, -3.5), ( 0.5, 1.8, -2.5),
            (-1.5, 2.5, -4.0), ( 1.5, 1.0, -2.0), (-0.5, 3.0, -3.8),
            ( 2.5, 1.5, -3.0), (-2.0, 1.8, -2.5), ( 0.0, 2.5, -4.5),
            ( 1.0, 0.8, -1.8), (-1.0, 1.5, -3.2), ( 2.2, 2.8, -4.0),
            (-2.8, 0.9, -3.5), ( 0.8, 2.2, -2.2), (-0.3, 1.0, -2.8),
            ( 1.8, 1.6, -4.2), (-1.8, 2.8, -3.0), ( 0.3, 3.2, -3.0),
            (-2.2, 2.0, -4.5), ( 2.8, 0.7, -2.5)
        ]
        let sizes: [Float] = [0.18, 0.25, 0.12, 0.30, 0.15, 0.22, 0.28, 0.10,
                              0.20, 0.35, 0.14, 0.24, 0.32, 0.16, 0.26, 0.11,
                              0.29, 0.21, 0.13, 0.27]

        for (i, pos) in positions.enumerated() {
            let color = colors[i % colors.count]
            let size = sizes[i % sizes.count]
            let mesh: MeshResource
            switch i % 3 {
            case 0: mesh = .generateSphere(radius: size)
            case 1: mesh = .generateBox(size: size)
            default: mesh = .generateCylinder(height: size * 2, radius: size * 0.5)
            }
            let entity = ModelEntity(
                mesh: mesh,
                materials: [SimpleMaterial(color: color, isMetallic: false)]
            )
            entity.position = [pos.0, pos.1, pos.2]
            content.add(entity)
        }
    }
}
