//
//  ISS.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit
import UIKit

struct ISS: SceneContent {
    func build(content: inout RealityViewContent) async {
        addSpace(to: &content)
        addStars(to: &content)
        addEarth(to: &content)
        addStation(to: &content)
    }

    private func rng(_ seed: Int) -> Float {
        let x = sin(Float(seed) * 127.1 + 311.7) * 43758.5
        return x - floor(x)
    }

    private func addSpace(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.0, green: 0.0, blue: 0.01, alpha: 1))
        mat.faceCulling = .front
        content.add(ModelEntity(mesh: .generateSphere(radius: 500), materials: [mat]))
    }

    private func addStars(to content: inout RealityViewContent) {
        let starColors: [UIColor] = [
            UIColor(white: 1.0, alpha: 1),
            UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1),
            UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1),
        ]
        for i in 0..<300 {
            var mat = UnlitMaterial()
            mat.color = .init(tint: starColors[i % starColors.count])
            let theta = rng(i * 3) * .pi * 2
            let phi = acos(2 * rng(i * 3 + 1) - 1)
            let r: Float = 490
            let star = ModelEntity(
                mesh: .generateSphere(radius: 0.2 + rng(i * 3 + 2) * 1.0),
                materials: [mat]
            )
            star.position = [
                r * sin(phi) * cos(theta),
                r * sin(phi) * sin(theta),
                r * cos(phi)
            ]
            content.add(star)
        }
    }

    private func addEarth(to content: inout RealityViewContent) {
        let earthCenter = SIMD3<Float>(0, -150, -30)
        let earthR: Float = 85

        // Direction from Earth center toward user — defines visible hemisphere
        let toUser = normalize(SIMD3<Float>(0, 150, 30))

        // Ocean base
        var oceanMat = UnlitMaterial()
        oceanMat.color = .init(tint: UIColor(red: 0.07, green: 0.22, blue: 0.60, alpha: 1))
        let earth = ModelEntity(mesh: .generateSphere(radius: earthR), materials: [oceanMat])
        earth.position = earthCenter
        content.add(earth)

        // Atmosphere glow
        var atmMat = UnlitMaterial()
        atmMat.color = .init(tint: UIColor(red: 0.28, green: 0.52, blue: 0.92, alpha: 0.35))
        atmMat.faceCulling = .front
        let atm = ModelEntity(mesh: .generateSphere(radius: earthR + 5), materials: [atmMat])
        atm.position = earthCenter
        content.add(atm)

        // Places a flat box ON the sphere surface, oriented to lie tangent to it
        func addPatch(dir: SIMD3<Float>, w: Float, d: Float, h: Float = 0.8, color: UIColor) {
            let n = normalize(dir)
            guard simd_dot(n, toUser) > -0.1 else { return } // only visible hemisphere
            var mat = UnlitMaterial()
            mat.color = .init(tint: color)
            let pos = earthCenter + n * (earthR + 0.6)
            let patch = ModelEntity(mesh: .generateBox(width: w, height: h, depth: d), materials: [mat])
            patch.position = pos
            patch.orientation = simd_quatf(from: [0, 1, 0], to: n)
            content.add(patch)
        }

        let land  = UIColor(red: 0.20, green: 0.45, blue: 0.18, alpha: 1)
        let desert = UIColor(red: 0.62, green: 0.52, blue: 0.28, alpha: 1)
        let ice   = UIColor(white: 0.95, alpha: 1)
        let cloud = UIColor(white: 1.0, alpha: 1)

        // Land masses — all on user-facing hemisphere
        addPatch(dir: [ 0.30,  0.90,  0.30], w: 24, d: 18, color: land)
        addPatch(dir: [-0.40,  0.85,  0.35], w: 20, d: 16, color: land)
        addPatch(dir: [ 0.60,  0.75,  0.10], w: 22, d: 16, color: desert)
        addPatch(dir: [-0.15,  0.92, -0.12], w: 16, d: 13, color: land)
        addPatch(dir: [ 0.10,  0.80, -0.30], w: 14, d: 11, color: land)
        addPatch(dir: [ 0.70,  0.65,  0.30], w: 18, d: 13, color: desert)
        addPatch(dir: [ 0.00,  0.99,  0.10], w: 18, d: 14, color: ice)   // north pole

        // Clouds — slightly higher than land
        addPatch(dir: [ 0.15,  0.95,  0.25], w: 28, d: 12, h: 1.0, color: cloud)
        addPatch(dir: [-0.30,  0.88,  0.40], w: 22, d: 10, h: 1.0, color: cloud)
        addPatch(dir: [ 0.50,  0.82,  0.20], w: 20, d:  9, h: 1.0, color: cloud)
        addPatch(dir: [-0.10,  0.90, -0.25], w: 24, d: 10, h: 1.0, color: cloud)
        addPatch(dir: [ 0.20,  0.78,  0.35], w: 18, d:  8, h: 1.0, color: cloud)
    }

    private func addStation(to content: inout RealityViewContent) {
        // Materials
        var trussMat = UnlitMaterial()
        trussMat.color = .init(tint: UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1))
        var moduleMat = UnlitMaterial()
        moduleMat.color = .init(tint: UIColor(red: 0.88, green: 0.88, blue: 0.90, alpha: 1))
        var solarMat = UnlitMaterial()
        solarMat.color = .init(tint: UIColor(red: 0.10, green: 0.18, blue: 0.50, alpha: 1))
        var solarFrameMat = UnlitMaterial()
        solarFrameMat.color = .init(tint: UIColor(red: 0.75, green: 0.75, blue: 0.78, alpha: 1))
        var radiatorMat = UnlitMaterial()
        radiatorMat.color = .init(tint: UIColor(red: 0.92, green: 0.92, blue: 0.94, alpha: 1))
        var cupMat = UnlitMaterial()
        cupMat.color = .init(tint: UIColor(red: 0.70, green: 0.72, blue: 0.75, alpha: 1))

        // ── MAIN TRUSS (ITS) ──────────────────────────────────────────
        // Horizontal backbone running left-right
        let mainTruss = ModelEntity(mesh: .generateBox(width: 90, height: 0.7, depth: 0.7), materials: [trussMat])
        mainTruss.position = [0, 2, -5]
        content.add(mainTruss)

        // Truss detail — parallel rails
        for dz: Float in [-0.6, 0.6] {
            let rail = ModelEntity(mesh: .generateBox(width: 90, height: 0.2, depth: 0.2), materials: [trussMat])
            rail.position = [0, 2, -5 + dz]
            content.add(rail)
        }

        // Cross-struts along truss
        for i in stride(from: -40, through: 40, by: 8) {
            let strut = ModelEntity(mesh: .generateBox(width: 0.15, height: 0.15, depth: 1.4), materials: [trussMat])
            strut.position = [Float(i), 2, -5]
            content.add(strut)
        }

        // ── HABITAT MODULES ───────────────────────────────────────────
        // US segment runs along Z from truss center
        let usModules: [(Float, Float, Float, Float)] = [
            // x,   y,    z,   length
            (0,   1.8,  -5,   5.0),   // Node 1 (Unity)
            (0,   1.8,  -8.5, 4.5),   // Destiny lab
            (0,   1.8, -12.0, 4.0),   // Node 2 (Harmony)
            (0,   1.8, -15.0, 5.5),   // Columbus/Kibo
            (0,   1.8, -19.0, 4.0),   // Node 3
        ]
        for m in usModules {
            let mod = ModelEntity(mesh: .generateCylinder(height: m.3, radius: 1.15), materials: [moduleMat])
            mod.position = [m.0, m.1, m.2]
            mod.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            content.add(mod)
        }

        // Russian segment extends in +Z direction
        let ruModules: [(Float, Float, Float, Float)] = [
            (0,  1.8,  -1.5, 4.0),   // Node/PMA
            (0,  1.8,   2.0, 5.0),   // Zarya
            (0,  1.8,   6.0, 5.5),   // Zvezda service module
        ]
        for m in ruModules {
            let mod = ModelEntity(mesh: .generateCylinder(height: m.3, radius: 1.05), materials: [moduleMat])
            mod.position = [m.0, m.1, m.2]
            mod.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            content.add(mod)
        }

        // Soyuz docked to Russian end
        let soyuz = ModelEntity(mesh: .generateCylinder(height: 3.0, radius: 0.6), materials: [moduleMat])
        soyuz.position = [0, 1.8, 9.5]
        soyuz.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
        content.add(soyuz)

        // Cupola (small dome on Node 3 — below)
        let cupola = ModelEntity(mesh: .generateCylinder(height: 1.5, radius: 0.9), materials: [cupMat])
        cupola.position = [0, 0.3, -19]
        content.add(cupola)

        // ── SOLAR ARRAY WINGS (4 pairs) ───────────────────────────────
        let solarXPositions: [(Float, Float)] = [(-38, -1), (-22, 1), (22, -1), (38, 1)]
        for (px, tilt) in solarXPositions {
            for sign: Float in [-1, 1] {
                // Panel
                let panel = ModelEntity(
                    mesh: .generateBox(width: 14, height: 0.06, depth: 5.5),
                    materials: [solarMat]
                )
                panel.position = [px, 2 + sign * 5.5, -5 + tilt]
                // Slight angle on outermost panels
                if abs(px) > 30 {
                    panel.orientation = simd_quatf(angle: sign * 0.08, axis: [1, 0, 0])
                }
                content.add(panel)

                // Frame lines
                for edge: Float in [-6.8, 6.8] {
                    let frame = ModelEntity(
                        mesh: .generateBox(width: 0.15, height: 0.12, depth: 5.5),
                        materials: [solarFrameMat]
                    )
                    frame.position = [px + edge, 2 + sign * 5.5, -5 + tilt]
                    content.add(frame)
                }
                // Mast connecting panel to truss
                let mast = ModelEntity(mesh: .generateBox(width: 0.2, height: sign * 10.5, depth: 0.2), materials: [trussMat])
                mast.position = [px, 2 + sign * 0.5, -5 + tilt]
                content.add(mast)
            }

            // Radiator panels between solar array pairs
            if abs(px) < 35 {
                let radiator = ModelEntity(
                    mesh: .generateBox(width: 1.5, height: 0.05, depth: 8),
                    materials: [radiatorMat]
                )
                radiator.position = [px + 8, 2, -5]
                content.add(radiator)
            }
        }

        // ── ROBOTIC ARM (CANADARM2) ───────────────────────────────────
        let armSegments: [(SIMD3<Float>, Float, Float)] = [
            ([8, 2.8, -5], 6, 0),       // upper arm
            ([11, 3.5, -5], 5, 0.4),    // lower arm
        ]
        for seg in armSegments {
            var armMat = UnlitMaterial()
            armMat.color = .init(tint: UIColor(red: 0.85, green: 0.85, blue: 0.60, alpha: 1))
            let arm = ModelEntity(mesh: .generateCylinder(height: seg.1, radius: 0.18), materials: [armMat])
            arm.position = seg.0
            arm.orientation = simd_quatf(angle: seg.2 + .pi / 2, axis: [0, 0, 1])
            content.add(arm)
        }

        // ── SUN ───────────────────────────────────────────────────────
        var sunMat = UnlitMaterial()
        sunMat.color = .init(tint: UIColor(red: 1.0, green: 0.97, blue: 0.85, alpha: 1))
        let sun = ModelEntity(mesh: .generateSphere(radius: 15), materials: [sunMat])
        sun.position = [250, 100, -350]
        content.add(sun)

        // Sun glow halo
        var haloMat = UnlitMaterial()
        haloMat.color = .init(tint: UIColor(red: 1.0, green: 0.90, blue: 0.60, alpha: 0.3))
        haloMat.faceCulling = .front
        let halo = ModelEntity(mesh: .generateSphere(radius: 22), materials: [haloMat])
        halo.position = [250, 100, -350]
        content.add(halo)
    }
}
