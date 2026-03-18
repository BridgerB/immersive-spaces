//
//  AncientEgypt.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit
import UIKit

private extension UIColor {
    func shaded(by factor: Float) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * CGFloat(factor), green: g * CGFloat(factor), blue: b * CGFloat(factor), alpha: a)
    }
}

struct AncientEgypt: SceneContent {
    func build(content: inout RealityViewContent) async {
        addSky(to: &content)
        addGround(to: &content)
        addDunes(to: &content)
        addPyramids(to: &content)
        addDetailedSphinx(to: &content)
        addSun(to: &content)
        addRubble(to: &content)
    }

    private func rng(_ seed: Int) -> Float {
        let x = sin(Float(seed) * 127.1 + 311.7) * 43758.5
        return x - floor(x)
    }

    private func addSky(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.52, green: 0.72, blue: 0.92, alpha: 1))
        mat.faceCulling = .front
        content.add(ModelEntity(mesh: .generateSphere(radius: 500), materials: [mat]))

        // Hazy horizon band
        var hazeMat = UnlitMaterial()
        hazeMat.color = .init(tint: UIColor(red: 0.88, green: 0.78, blue: 0.55, alpha: 1))
        let haze = ModelEntity(mesh: .generateSphere(radius: 1), materials: [hazeMat])
        haze.scale = [1000, 30, 1000]
        haze.position = [0, -30, 0]
        content.add(haze)
    }

    private func addGround(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.82, green: 0.70, blue: 0.45, alpha: 1))
        let ground = ModelEntity(mesh: .generateBox(width: 1000, height: 0.1, depth: 1000), materials: [mat])
        ground.position = [0, -0.05, 0]
        content.add(ground)
    }

    private func addDunes(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.78, green: 0.65, blue: 0.38, alpha: 1))

        let dunes: [(Float, Float, Float, Float, Float)] = [
            (-80, -50, 40, 4, 30),
            ( 90, -60, 35, 5, 25),
            (-50, -80, 50, 6, 38),
            (  0, -90, 45, 4, 35),
            (120, -40, 30, 3, 22),
            (-120, -45, 38, 5, 28),
            ( 60, -100, 55, 7, 42),
        ]
        for d in dunes {
            let dune = ModelEntity(mesh: .generateSphere(radius: 1), materials: [mat])
            dune.position = [d.0, 0, d.1]
            dune.scale = [d.2, d.3, d.4]
            content.add(dune)
        }
    }

    private func addSteppedPyramid(x: Float, z: Float, height: Float, baseWidth: Float, layers: Int, color: UIColor, to content: inout RealityViewContent) {
        let layerH = height / Float(layers)
        for i in 0..<layers {
            let t = Float(i) / Float(layers)
            let w = baseWidth * (1.0 - t) + 0.5
            let shade = 1.0 - t * 0.15  // slightly darker near top
            var mat = UnlitMaterial()
            mat.color = .init(tint: color.withAlphaComponent(1).shaded(by: shade))
            let layer = ModelEntity(
                mesh: .generateBox(width: w, height: layerH, depth: w),
                materials: [mat]
            )
            layer.position = [x, layerH * 0.5 + Float(i) * layerH, z]
            content.add(layer)
        }
    }

    private func addPyramids(to content: inout RealityViewContent) {
        // Great Pyramid of Khufu — moved back so Sphinx has room
        addSteppedPyramid(x: 18, z: -60, height: 40, baseWidth: 56, layers: 16,
                          color: UIColor(red: 0.80, green: 0.68, blue: 0.46, alpha: 1), to: &content)
        // Pyramid of Khafre
        addSteppedPyramid(x: -15, z: -80, height: 36, baseWidth: 50, layers: 14,
                          color: UIColor(red: 0.75, green: 0.63, blue: 0.42, alpha: 1), to: &content)
        // Pyramid of Menkaure
        addSteppedPyramid(x: -42, z: -95, height: 20, baseWidth: 30, layers: 10,
                          color: UIColor(red: 0.72, green: 0.60, blue: 0.40, alpha: 1), to: &content)
    }

    private func addSphinx(to content: inout RealityViewContent) {
        var bodyMat = UnlitMaterial()
        bodyMat.color = .init(tint: UIColor(red: 0.76, green: 0.64, blue: 0.42, alpha: 1))
        var headMat = UnlitMaterial()
        headMat.color = .init(tint: UIColor(red: 0.72, green: 0.60, blue: 0.38, alpha: 1))

        // Body — long horizontal mass
        let body = ModelEntity(mesh: .generateBox(width: 5, height: 3.5, depth: 12), materials: [bodyMat])
        body.position = [10, 1.75, -16]
        content.add(body)

        // Paws
        for dx: Float in [-1.5, 1.5] {
            let paw = ModelEntity(mesh: .generateBox(width: 1.5, height: 1, depth: 3), materials: [bodyMat])
            paw.position = [10 + dx, 0.5, -10.5]
            content.add(paw)
        }

        // Neck
        let neck = ModelEntity(mesh: .generateCylinder(height: 2.5, radius: 1.2), materials: [headMat])
        neck.position = [10, 4.8, -13]
        content.add(neck)

        // Head
        let head = ModelEntity(mesh: .generateBox(width: 2.8, height: 2.5, depth: 3.0), materials: [headMat])
        head.position = [10, 6.2, -12.5]
        content.add(head)

        // Headdress (nemes)
        let nemes = ModelEntity(mesh: .generateBox(width: 3.5, height: 3.0, depth: 2.5), materials: [headMat])
        nemes.position = [10, 6.0, -12.0]
        content.add(nemes)
    }

    private func addDetailedSphinx(to content: inout RealityViewContent) {
        let cx: Float = 10
        let cz: Float = -16

        func add(_ mesh: MeshResource, _ color: UIColor, _ x: Float, _ y: Float, _ z: Float,
                 _ sx: Float = 1, _ sy: Float = 1, _ sz: Float = 1) {
            var mat = UnlitMaterial()
            mat.color = .init(tint: color)
            let e = ModelEntity(mesh: mesh, materials: [mat])
            e.position = [cx + x, y, cz - z]
            if sx != 1 || sy != 1 || sz != 1 { e.scale = [sx, sy, sz] }
            content.add(e)
        }

        let stone  = UIColor(red: 0.76, green: 0.64, blue: 0.42, alpha: 1)
        let dark   = UIColor(red: 0.52, green: 0.43, blue: 0.28, alpha: 1)
        let light  = UIColor(red: 0.88, green: 0.76, blue: 0.54, alpha: 1)
        let shadow = UIColor(red: 0.45, green: 0.37, blue: 0.24, alpha: 1)

        // Platform
        add(.generateBox(width: 8, height: 0.5, depth: 16), dark, 0, 0.25, 0)

        // Main body
        add(.generateBox(width: 5, height: 3.5, depth: 11), stone, 0, 2.0, 0)

        // Haunches
        for dx: Float in [-2.2, 2.2] {
            add(.generateBox(width: 2, height: 4.0, depth: 3.5), stone, dx, 2.0, 3.5)
        }

        // Shoulders
        for dx: Float in [-2.0, 2.0] {
            add(.generateBox(width: 1.8, height: 4.2, depth: 2.5), stone, dx, 2.1, -2.5)
        }

        // Chest panel
        add(.generateBox(width: 4.8, height: 3.8, depth: 0.3), light, 0, 2.2, -5.8)

        // Paws
        for dx: Float in [-1.4, 1.4] {
            add(.generateBox(width: 1.3, height: 0.9, depth: 5.0), stone, dx, 0.7, -8.0)
            for toe: Float in [-0.35, 0, 0.35] {
                add(.generateBox(width: 0.35, height: 0.5, depth: 0.6), dark, dx + toe, 0.5, -10.6)
            }
        }
        add(.generateBox(width: 1.4, height: 0.6, depth: 5.0), shadow, 0, 0.4, -8.0)

        // Tail
        add(.generateBox(width: 0.6, height: 0.5, depth: 3.0), stone, 1.5, 3.6, 4.5)
        add(.generateBox(width: 0.6, height: 1.2, depth: 0.5), stone, 1.5, 4.5, 5.8)

        // Neck
        add(.generateBox(width: 2.4, height: 2.8, depth: 2.0), stone, 0, 4.8, -5.2)

        // Head
        add(.generateBox(width: 2.6, height: 2.6, depth: 2.8), stone, 0, 7.0, -5.0)

        // Brow ridge
        add(.generateBox(width: 2.6, height: 0.4, depth: 0.3), dark, 0, 8.0, -6.3)

        // Eyes
        for dx: Float in [-0.7, 0.7] {
            add(.generateBox(width: 0.55, height: 0.35, depth: 0.25), shadow, dx, 7.6, -6.35)
            add(.generateBox(width: 0.30, height: 0.20, depth: 0.30), dark, dx, 7.6, -6.5)
        }

        // Cheekbones
        for dx: Float in [-1.1, 1.1] {
            add(.generateBox(width: 0.5, height: 0.6, depth: 0.25), light, dx, 7.0, -6.3)
        }

        // Nose
        add(.generateBox(width: 0.7, height: 0.5, depth: 0.2), stone, 0, 6.6, -6.35)

        // Mouth
        add(.generateBox(width: 1.0, height: 0.15, depth: 0.2), shadow, 0, 6.1, -6.35)
        add(.generateBox(width: 1.0, height: 0.3, depth: 0.25), stone, 0, 6.0, -6.35)

        // Beard
        add(.generateBox(width: 0.7, height: 1.8, depth: 0.6), dark, 0, 4.8, -6.2)
        add(.generateBox(width: 0.5, height: 0.5, depth: 0.5), dark, 0, 3.9, -6.1)

        // Nemes crown
        add(.generateBox(width: 3.4, height: 0.6, depth: 2.6), light, 0, 8.4, -4.9)

        // Nemes side panels with stripes
        for dx: Float in [-1.5, 1.5] {
            add(.generateBox(width: 0.7, height: 3.0, depth: 0.4), stone, dx, 6.5, -4.8)
            for sy: Float in [0, 0.7, 1.4, 2.1] {
                add(.generateBox(width: 0.7, height: 0.12, depth: 0.45), dark, dx, 5.0 + sy, -4.8)
            }
        }

        // Nemes back
        add(.generateBox(width: 2.0, height: 2.5, depth: 0.4), stone, 0, 6.5, -3.8)

        // Uraeus cobra
        add(.generateCylinder(height: 0.8, radius: 0.15), dark, 0, 8.9, -6.0)
        add(.generateSphere(radius: 0.22), dark, 0, 9.6, -6.1)
    }

    private func addSun(to content: inout RealityViewContent) {
        var sunMat = UnlitMaterial()
        sunMat.color = .init(tint: UIColor(red: 1.0, green: 0.97, blue: 0.75, alpha: 1))
        let sun = ModelEntity(mesh: .generateSphere(radius: 8), materials: [sunMat])
        sun.position = [80, 120, -200]
        content.add(sun)

        var haloMat = UnlitMaterial()
        haloMat.color = .init(tint: UIColor(red: 1.0, green: 0.90, blue: 0.55, alpha: 0.25))
        haloMat.faceCulling = .front
        let halo = ModelEntity(mesh: .generateSphere(radius: 14), materials: [haloMat])
        halo.position = [80, 120, -200]
        content.add(halo)
    }

    private func addRubble(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.68, green: 0.57, blue: 0.38, alpha: 1))

        for i in 0..<40 {
            let x = (rng(i * 5) - 0.5) * 60
            let z = -(2 + rng(i * 5 + 1) * 50)
            let s = 0.2 + rng(i * 5 + 2) * 0.8
            let rock = ModelEntity(
                mesh: i % 2 == 0 ? .generateBox(size: s) : .generateSphere(radius: s * 0.5),
                materials: [mat]
            )
            rock.position = [x, s * 0.25, z]
            content.add(rock)
        }
    }
}
