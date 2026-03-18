//
//  BigSurScene.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit
import UIKit

struct BigSur: SceneContent {
    func build(content: inout RealityViewContent) async {
        addSky(to: &content)
        addBluff(to: &content)
        addOcean(to: &content)
        addMountains(to: &content)
        addCypressTrees(to: &content)
        addCliffEdge(to: &content)
        addRocks(to: &content)
    }

    private func rng(_ seed: Int) -> Float {
        let x = sin(Float(seed) * 127.1 + 311.7) * 43758.5
        return x - floor(x)
    }

    private func addSky(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.55, green: 0.72, blue: 0.90, alpha: 1))
        mat.faceCulling = .front
        content.add(ModelEntity(mesh: .generateSphere(radius: 500), materials: [mat]))
    }

    private func addBluff(to content: inout RealityViewContent) {
        // Grassy bluff behind and around you — stops at z=0 so ocean is visible in front
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.40, green: 0.50, blue: 0.25, alpha: 1))
        let bluff = ModelEntity(
            mesh: .generateBox(width: 400, height: 0.1, depth: 200),
            materials: [mat]
        )
        bluff.position = [0, -0.05, 100]  // centered 100m behind you, so front edge is at z=0
        content.add(bluff)
    }

    private func addOcean(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.04, green: 0.28, blue: 0.48, alpha: 1))
        // Ocean fills everything in front of z=0, slightly below bluff level
        let ocean = ModelEntity(
            mesh: .generateBox(width: 1000, height: 0.1, depth: 1000),
            materials: [mat]
        )
        ocean.position = [0, -20, -500]  // 20m below bluff
        content.add(ocean)
    }

    private func addMountains(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.26, green: 0.30, blue: 0.20, alpha: 1))

        let count = 22
        for i in 0..<count {
            let t = Float(i) / Float(count)
            let angle = (.pi * 0.1) + t * (.pi * 0.8)  // sweep behind you
            let dist = 40 + rng(i * 3) * 60
            let x = cos(angle) * dist + (rng(i * 3 + 1) - 0.5) * 20
            let z = abs(sin(angle)) * dist  // keep positive (behind)
            let height = 20 + rng(i * 7) * 35
            let radius = 6 + rng(i * 7 + 1) * 8

            let cone = ModelEntity(mesh: .generateCone(height: height, radius: radius), materials: [mat])
            cone.position = [x, height / 2, z]
            content.add(cone)
        }
    }

    private func addCypressTrees(to content: inout RealityViewContent) {
        var trunkMat = UnlitMaterial()
        trunkMat.color = .init(tint: UIColor(red: 0.28, green: 0.20, blue: 0.13, alpha: 1))
        var foliageMat = UnlitMaterial()
        foliageMat.color = .init(tint: UIColor(red: 0.13, green: 0.25, blue: 0.16, alpha: 1))

        let count = 50
        for i in 0..<count {
            let angle = rng(i * 5) * .pi  // only behind (0 to π keeps z positive)
            let dist = 6 + rng(i * 5 + 1) * 35
            let x = cos(angle) * dist
            let z = sin(angle) * dist
            if z < 1 { continue }  // stay behind cliff edge

            let scale = 0.9 + rng(i * 5 + 3) * 1.6
            let trunkH: Float = 1.5 * scale
            let trunk = ModelEntity(mesh: .generateCylinder(height: trunkH, radius: 0.1 * scale), materials: [trunkMat])
            trunk.position = [x, trunkH / 2, z]
            content.add(trunk)

            let foliageH: Float = 5.0 * scale
            let foliage = ModelEntity(mesh: .generateCone(height: foliageH, radius: 0.5 * scale), materials: [foliageMat])
            foliage.position = [x, trunkH + foliageH / 2, z]
            content.add(foliage)
        }
    }

    private func addCliffEdge(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.48, green: 0.42, blue: 0.34, alpha: 1))

        // Irregular cliff edge — segments along x axis with varying z and height
        let cliffHeight: Float = 20.0
        let segments = 50
        for i in 0..<segments {
            let x = Float(i - segments / 2) * 5.5
            let zOffset = (rng(i * 3) - 0.5) * 6.0       // jag in/out ±3m
            let extraHeight = rng(i * 3 + 1) * 6.0        // random extra height variation
            let h = cliffHeight + extraHeight
            let width = 5.5 + rng(i * 3 + 2) * 3.0

            let block = ModelEntity(
                mesh: .generateBox(width: width, height: h, depth: 2.0 + rng(i * 3 + 2) * 3),
                materials: [mat]
            )
            // Top at y=-0.2 (just below grass) so no z-fighting
            block.position = [x, -0.2 - h / 2, zOffset]
            content.add(block)
        }
    }

    private func addRocks(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.30, green: 0.27, blue: 0.24, alpha: 1))

        for i in 0..<25 {
            let x = (rng(i * 7) - 0.5) * 80
            let z = -(3 + rng(i * 7 + 1) * 40)
            let sx = 1.0 + rng(i * 7 + 2) * 3.0
            let sy = 0.4 + rng(i * 7 + 3) * 1.2
            let sz = 0.8 + rng(i * 7 + 4) * 2.5
            let rock = ModelEntity(mesh: .generateSphere(radius: 1), materials: [mat])
            rock.position = [x, -19, z]
            rock.scale = [sx, sy, sz]
            content.add(rock)
        }
    }
}
