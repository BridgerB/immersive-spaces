//
//  MountainScene.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit
import UIKit

struct MountainScene: SceneContent {
    func build(content: inout RealityViewContent) async {
        addSky(to: &content)
        addGround(to: &content)
        addMountains(to: &content)
        addTrees(to: &content)
        addLake(to: &content)
    }

    // Simple deterministic pseudo-random sequence
    private func rng(_ seed: Int) -> Float {
        let x = sin(Float(seed) * 127.1 + 311.7) * 43758.5
        return x - floor(x)
    }

    private func addSky(to content: inout RealityViewContent) {
        var skyMat = UnlitMaterial()
        skyMat.color = .init(tint: UIColor(red: 0.40, green: 0.65, blue: 0.95, alpha: 1))
        skyMat.faceCulling = .front
        let sky = ModelEntity(mesh: .generateSphere(radius: 500), materials: [skyMat])
        sky.position = [0, 0, 0]
        content.add(sky)
    }

    private func addGround(to content: inout RealityViewContent) {
        var groundMat = UnlitMaterial()
        groundMat.color = .init(tint: UIColor(red: 0.25, green: 0.40, blue: 0.15, alpha: 1))
        let ground = ModelEntity(
            mesh: .generateBox(width: 1000, height: 0.1, depth: 1000),
            materials: [groundMat]
        )
        ground.position = [0, -0.05, 0]
        content.add(ground)
    }

    private func addMountains(to content: inout RealityViewContent) {
        let mountainColor = UIColor(red: 0.52, green: 0.56, blue: 0.62, alpha: 1)
        let count = 200
        for i in 0..<count {
            let angle = Float(i) / Float(count) * .pi * 2
            let dist = 60 + rng(i * 3) * 60        // 60–120m away
            let x = cos(angle) * dist + (rng(i * 3 + 1) - 0.5) * 15
            let z = sin(angle) * dist + (rng(i * 3 + 2) - 0.5) * 15
            let height = 12 + rng(i * 7) * 23      // 12–35m tall
            let radius = 6 + rng(i * 7 + 1) * 10   // 6–16m wide

            let cone = ModelEntity(
                mesh: .generateCone(height: height, radius: radius),
                materials: [SimpleMaterial(color: mountainColor, isMetallic: false)]
            )
            cone.position = [x, height / 2, z]
            content.add(cone)

            let snowHeight = height * 0.25
            let snow = ModelEntity(
                mesh: .generateCone(height: snowHeight, radius: radius * 0.3),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            snow.position = [x, height * 0.88, z]
            content.add(snow)
        }
    }

    private func addTrees(to content: inout RealityViewContent) {
        let trunkColor = UIColor(red: 0.40, green: 0.26, blue: 0.13, alpha: 1)
        let foliageColors: [UIColor] = [
            UIColor(red: 0.10, green: 0.40, blue: 0.12, alpha: 1),
            UIColor(red: 0.15, green: 0.50, blue: 0.18, alpha: 1),
            UIColor(red: 0.08, green: 0.35, blue: 0.10, alpha: 1),
        ]
        let count = 300
        for i in 0..<count {
            let angle = rng(i * 5) * .pi * 2
            let dist = 8 + rng(i * 5 + 1) * 37     // 8–45m away
            let x = cos(angle) * dist
            let z = sin(angle) * dist

            // Skip trees inside the lake
            if abs(x) < 10 && z > -20 && z < -6 { continue }

            let scale = 0.8 + rng(i * 5 + 3) * 1.7  // 0.8–2.5x
            let trunkHeight = 0.7 * scale
            let trunk = ModelEntity(
                mesh: .generateCylinder(height: trunkHeight, radius: 0.07 * scale),
                materials: [SimpleMaterial(color: trunkColor, isMetallic: false)]
            )
            trunk.position = [x, trunkHeight / 2, z]
            content.add(trunk)

            let foliageHeight = 1.3 * scale
            let foliage = ModelEntity(
                mesh: .generateCone(height: foliageHeight, radius: 0.48 * scale),
                materials: [SimpleMaterial(color: foliageColors[i % foliageColors.count], isMetallic: false)]
            )
            foliage.position = [x, trunkHeight + foliageHeight / 2, z]
            content.add(foliage)
        }
    }

    private func addLake(to content: inout RealityViewContent) {
        var lakeMat = UnlitMaterial()
        lakeMat.color = .init(tint: UIColor(red: 0.15, green: 0.45, blue: 0.75, alpha: 1))

        // Oval lake: flattened sphere scaled to oval shape
        let lake = ModelEntity(mesh: .generateSphere(radius: 1), materials: [lakeMat])
        lake.position = [0, 0.01, -12]
        lake.scale = [14, 0.02, 9]
        content.add(lake)

        // Irregular shoreline chunks
        let chunks: [(Float, Float, Float, Float)] = [
            (-5.5, -11.0, 2.5, 2.0),
            ( 4.8, -13.5, 3.0, 1.8),
            (-3.0, -14.5, 2.0, 1.5),
            ( 2.5, -10.5, 2.2, 1.6),
        ]
        for c in chunks {
            let chunk = ModelEntity(mesh: .generateSphere(radius: 1), materials: [lakeMat])
            chunk.position = [c.0, 0.01, c.1]
            chunk.scale = [c.2, 0.02, c.3]
            content.add(chunk)
        }
    }
}
