//
//  TimesSquare.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit
import UIKit

struct TimesSquare: SceneContent {
    func build(content: inout RealityViewContent) async {
        addSky(to: &content)
        addGround(to: &content)
        addBuildings(to: &content)
        addBillboards(to: &content)
        addStreetLights(to: &content)
    }

    private func rng(_ seed: Int) -> Float {
        let x = sin(Float(seed) * 127.1 + 311.7) * 43758.5
        return x - floor(x)
    }

    private func addSky(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.04, green: 0.04, blue: 0.10, alpha: 1))
        mat.faceCulling = .front
        content.add(ModelEntity(mesh: .generateSphere(radius: 500), materials: [mat]))
    }

    private func addGround(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1))
        let ground = ModelEntity(mesh: .generateBox(width: 200, height: 0.1, depth: 200), materials: [mat])
        ground.position = [0, -0.05, 0]
        content.add(ground)

        // Yellow taxi stripes
        var taxiMat = UnlitMaterial()
        taxiMat.color = .init(tint: UIColor(red: 0.90, green: 0.72, blue: 0.05, alpha: 1))
        let stripePositions: [(Float, Float)] = [(-8, -5), (6, -12), (-5, -20), (9, -8)]
        for pos in stripePositions {
            let taxi = ModelEntity(mesh: .generateBox(width: 2.0, height: 0.11, depth: 4.5), materials: [taxiMat])
            taxi.position = [pos.0, 0, pos.1]
            content.add(taxi)
        }
    }

    private func addBuildings(to content: inout RealityViewContent) {
        let buildingColors: [UIColor] = [
            UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1), // dark grey
            UIColor(red: 0.28, green: 0.22, blue: 0.18, alpha: 1), // brown-grey
            UIColor(red: 0.20, green: 0.26, blue: 0.28, alpha: 1), // steel blue-grey
            UIColor(red: 0.24, green: 0.20, blue: 0.28, alpha: 1), // dark purple-grey
            UIColor(red: 0.30, green: 0.28, blue: 0.22, alpha: 1), // warm tan-grey
            UIColor(red: 0.16, green: 0.22, blue: 0.20, alpha: 1), // dark teal-grey
        ]
        var lightMat = UnlitMaterial()
        lightMat.color = .init(tint: UIColor(red: 0.85, green: 0.80, blue: 0.65, alpha: 1))

        // Buildings lining both sides of the street and behind
        let buildings: [(x: Float, z: Float, w: Float, d: Float, h: Float)] = [
            // Left side
            (-18,  -5, 10, 12, 60),
            (-20, -20, 12, 10, 90),
            (-17, -35,  9, 11, 50),
            (-19, -50, 11, 12, 75),
            // Right side
            ( 18,  -5, 10, 12, 70),
            ( 20, -20, 12, 10, 55),
            ( 17, -35,  9, 11, 85),
            ( 19, -50, 11, 12, 65),
            // Behind
            (-10,  15, 14, 10, 45),
            (  0,  18, 12, 10, 80),
            ( 12,  15, 14, 10, 55),
            // Far back fill
            (-22,  -8,  8,  8, 100),
            ( 22,  -8,  8,  8, 95),
            (  0, -60, 30, 15, 70),
        ]

        for (i, b) in buildings.enumerated() {
            var buildingMat = UnlitMaterial()
            buildingMat.color = .init(tint: buildingColors[i % buildingColors.count])
            let building = ModelEntity(
                mesh: .generateBox(width: b.w, height: b.h, depth: b.d),
                materials: [buildingMat]
            )
            building.position = [b.x, b.h / 2, b.z]
            content.add(building)

            // Random lit windows as thin offset panels
            let winRows = Int(b.h / 4)
            for row in 0..<winRows {
                if rng(row * 7 + Int(b.x)) > 0.5 {
                    let win = ModelEntity(
                        mesh: .generateBox(width: b.w * 0.7, height: 1.2, depth: 0.1),
                        materials: [lightMat]
                    )
                    let face: Float = b.x < 0 ? b.d / 2 + 0.1 : -(b.d / 2 + 0.1)
                    win.position = [b.x, 3 + Float(row) * 4, b.z + face]
                    content.add(win)
                }
            }
        }
    }

    private func addBillboards(to content: inout RealityViewContent) {
        let billboardColors: [UIColor] = [
            UIColor(red: 1.0, green: 0.10, blue: 0.10, alpha: 1),  // red
            UIColor(red: 0.0, green: 0.80, blue: 1.0,  alpha: 1),  // cyan
            UIColor(red: 1.0, green: 0.85, blue: 0.0,  alpha: 1),  // yellow
            UIColor(red: 0.0, green: 1.0,  blue: 0.40, alpha: 1),  // green
            UIColor(red: 1.0, green: 0.40, blue: 0.0,  alpha: 1),  // orange
            UIColor(red: 0.80, green: 0.0, blue: 1.0,  alpha: 1),  // purple
            UIColor(red: 1.0, green: 1.0,  blue: 1.0,  alpha: 1),  // white
        ]

        let billboards: [(x: Float, y: Float, z: Float, w: Float, h: Float, onLeft: Bool)] = [
            (-12, 18, -8,  14, 8,  true),
            (-12, 28, -18, 10, 6,  true),
            (-13, 12, -30, 12, 7,  true),
            ( 12, 20, -10, 14, 8,  false),
            ( 13, 14, -25, 10, 6,  false),
            ( 12, 32, -18, 16, 9,  false),
            (  0, 22, -55, 28, 12, false),
        ]

        for (i, b) in billboards.enumerated() {
            var mat = UnlitMaterial()
            mat.color = .init(tint: billboardColors[i % billboardColors.count])
            let board = ModelEntity(mesh: .generateBox(width: b.w, height: b.h, depth: 0.3), materials: [mat])
            board.position = [b.x, b.y, b.z]
            content.add(board)

            // Inner panel — contrasting color
            var innerMat = UnlitMaterial()
            innerMat.color = .init(tint: billboardColors[(i + 3) % billboardColors.count])
            let inner = ModelEntity(mesh: .generateBox(width: b.w * 0.6, height: b.h * 0.6, depth: 0.4), materials: [innerMat])
            inner.position = [b.x, b.y, b.z]
            content.add(inner)
        }
    }

    private func addStreetLights(to content: inout RealityViewContent) {
        var poleMat = UnlitMaterial()
        poleMat.color = .init(tint: UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1))
        var glowMat = UnlitMaterial()
        glowMat.color = .init(tint: UIColor(red: 1.0, green: 0.95, blue: 0.80, alpha: 1))

        let positions: [(Float, Float)] = [
            (-7, -6), (-7, -18), (-7, -32), (-7, -46),
            ( 7, -6), ( 7, -18), ( 7, -32), ( 7, -46),
        ]

        for pos in positions {
            let pole = ModelEntity(mesh: .generateCylinder(height: 8, radius: 0.1), materials: [poleMat])
            pole.position = [pos.0, 4, pos.1]
            content.add(pole)

            let glow = ModelEntity(mesh: .generateSphere(radius: 0.35), materials: [glowMat])
            glow.position = [pos.0, 8.2, pos.1]
            content.add(glow)
        }
    }
}
