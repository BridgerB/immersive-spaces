//
//  CherryBlossomGarden.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit
import UIKit

struct CherryBlossomGarden: SceneContent {
    func build(content: inout RealityViewContent) async {
        addSky(to: &content)
        addGround(to: &content)
        addPonds(to: &content)
        addBridge(to: &content)
        addSteppingStones(to: &content)
        addCherryTrees(to: &content)
        addEvergreens(to: &content)
        addPetals(to: &content)
        addFlowerBushes(to: &content)
        addToriiGates(to: &content)
        addLanterns(to: &content)
        addBambooFence(to: &content)
        addPagoda(to: &content)
        addRockGarden(to: &content)
    }

    private func rng(_ seed: Int) -> Float {
        let x = sin(Float(seed) * 127.1 + 311.7) * 43758.5
        return x - floor(x)
    }

    // MARK: - Sky

    private func addSky(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.90, green: 0.82, blue: 0.88, alpha: 1))
        mat.faceCulling = .front
        content.add(ModelEntity(mesh: .generateSphere(radius: 500), materials: [mat]))

        var hazeMat = UnlitMaterial()
        hazeMat.color = .init(tint: UIColor(red: 0.96, green: 0.90, blue: 0.93, alpha: 1))
        let haze = ModelEntity(mesh: .generateSphere(radius: 1), materials: [hazeMat])
        haze.scale = [1000, 18, 1000]
        haze.position = [0, -18, 0]
        content.add(haze)
    }

    // MARK: - Ground & Paths

    private func addGround(to content: inout RealityViewContent) {
        var mossMat = UnlitMaterial()
        mossMat.color = .init(tint: UIColor(red: 0.30, green: 0.46, blue: 0.22, alpha: 1))
        let ground = ModelEntity(mesh: .generateBox(width: 200, height: 0.1, depth: 200), materials: [mossMat])
        ground.position = [0, -0.05, 0]
        content.add(ground)

        var gravelMat = UnlitMaterial()
        gravelMat.color = .init(tint: UIColor(red: 0.72, green: 0.68, blue: 0.60, alpha: 1))

        // Main central path
        let mainPath = ModelEntity(mesh: .generateBox(width: 1.8, height: 0.08, depth: 40), materials: [gravelMat])
        mainPath.position = [0, 0.02, -14]
        content.add(mainPath)

        // Left branch path
        let leftPath = ModelEntity(mesh: .generateBox(width: 16, height: 0.08, depth: 1.6), materials: [gravelMat])
        leftPath.position = [-7, 0.02, -22]
        content.add(leftPath)

        // Right branch path
        let rightPath = ModelEntity(mesh: .generateBox(width: 14, height: 0.08, depth: 1.6), materials: [gravelMat])
        rightPath.position = [6, 0.02, -15]
        content.add(rightPath)

        // Diagonal path to second torii
        let diagPath1 = ModelEntity(mesh: .generateBox(width: 1.4, height: 0.08, depth: 10), materials: [gravelMat])
        diagPath1.position = [-6, 0.02, -30]
        diagPath1.orientation = simd_quatf(angle: 0.35, axis: [0, 1, 0])
        content.add(diagPath1)

        // Circular path around main pond
        for i in 0..<12 {
            let angle = Float(i) / 12 * .pi * 2
            let r: Float = 8.5
            let seg = ModelEntity(mesh: .generateBox(width: 1.4, height: 0.07, depth: 1.6), materials: [gravelMat])
            seg.position = [-6 + cos(angle) * r, 0.02, -15 + sin(angle) * r]
            seg.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])
            content.add(seg)
        }

        // Moss texture patches
        var darkMoss = UnlitMaterial()
        darkMoss.color = .init(tint: UIColor(red: 0.22, green: 0.38, blue: 0.16, alpha: 1))
        for i in 0..<25 {
            let patch = ModelEntity(mesh: .generateSphere(radius: 1), materials: [darkMoss])
            patch.position = [(rng(i*3) - 0.5) * 40, 0.02, -(rng(i*3+1) * 40)]
            patch.scale = [1.5 + rng(i*3+2) * 2.5, 0.05, 1.2 + rng(i*3+2) * 2.0]
            content.add(patch)
        }
    }

    // MARK: - Ponds

    private func addPonds(to content: inout RealityViewContent) {
        var waterMat = UnlitMaterial()
        waterMat.color = .init(tint: UIColor(red: 0.16, green: 0.35, blue: 0.42, alpha: 1))
        var stoneMat = UnlitMaterial()
        stoneMat.color = .init(tint: UIColor(red: 0.52, green: 0.50, blue: 0.46, alpha: 1))
        var lilyMat = UnlitMaterial()
        lilyMat.color = .init(tint: UIColor(red: 0.20, green: 0.46, blue: 0.18, alpha: 1))
        var lotusMat = UnlitMaterial()
        lotusMat.color = .init(tint: UIColor(red: 0.98, green: 0.72, blue: 0.78, alpha: 1))
        var koiColors: [UnlitMaterial] = []
        for c in [UIColor(red:0.95,green:0.45,blue:0.10,alpha:1),
                  UIColor(white:0.95,alpha:1),
                  UIColor(red:0.80,green:0.15,blue:0.10,alpha:1)] {
            var m = UnlitMaterial(); m.color = .init(tint: c); koiColors.append(m)
        }

        func addPond(cx: Float, cz: Float, sw: Float, sd: Float) {
            let pond = ModelEntity(mesh: .generateSphere(radius: 1), materials: [waterMat])
            pond.position = [cx, 0.03, cz]; pond.scale = [sw, 0.06, sd]; content.add(pond)

            // Ripple rings on surface
            var rippleMat = UnlitMaterial()
            rippleMat.color = .init(tint: UIColor(red: 0.25, green: 0.48, blue: 0.55, alpha: 1))
            for r: Float in [0.4, 0.65, 0.85] {
                let ring = ModelEntity(mesh: .generateCylinder(height: 0.02, radius: r), materials: [rippleMat])
                ring.position = [cx, 0.05, cz]; ring.scale = [sw * 0.9, 1, sd * 0.9]; content.add(ring)
            }

            // Edge stones
            for i in 0..<14 {
                let a = Float(i) / 14 * .pi * 2
                let ex = cx + cos(a) * sw * 0.95
                let ez = cz + sin(a) * sd * 0.95
                let s = ModelEntity(mesh: .generateSphere(radius: 1), materials: [stoneMat])
                s.position = [ex, 0.1, ez]
                s.scale = [0.35 + rng(i*5)*0.3, 0.15, 0.28 + rng(i*5+1)*0.25]
                content.add(s)
            }

            // Lily pads + lotus
            for i in 0..<8 {
                let lx = cx + (rng(i*7) - 0.5) * sw * 1.4
                let lz = cz + (rng(i*7+1) - 0.5) * sd * 1.4
                let lily = ModelEntity(mesh: .generateSphere(radius: 1), materials: [lilyMat])
                lily.position = [lx, 0.06, lz]; lily.scale = [0.32, 0.04, 0.28]; content.add(lily)
                if i % 3 == 0 {
                    let lotus = ModelEntity(mesh: .generateSphere(radius: 0.12), materials: [lotusMat])
                    lotus.position = [lx, 0.18, lz]; content.add(lotus)
                }
            }

            // Koi fish
            for i in 0..<4 {
                let koi = ModelEntity(mesh: .generateSphere(radius: 1), materials: [koiColors[i % koiColors.count]])
                koi.position = [cx + (rng(i*11)-0.5)*sw, 0.10, cz + (rng(i*11+1)-0.5)*sd]
                koi.scale = [0.28, 0.10, 0.12]; content.add(koi)
            }
        }

        // Main large pond
        addPond(cx: -6, cz: -16, sw: 6.0, sd: 4.2)
        // Second smaller pond right side
        addPond(cx: 9, cz: -20, sw: 3.5, sd: 2.5)
    }

    // MARK: - Bridge

    private func addBridge(to content: inout RealityViewContent) {
        var woodMat = UnlitMaterial()
        woodMat.color = .init(tint: UIColor(red: 0.45, green: 0.28, blue: 0.14, alpha: 1))
        var railMat = UnlitMaterial()
        railMat.color = .init(tint: UIColor(red: 0.38, green: 0.22, blue: 0.10, alpha: 1))

        // Bridge runs along X axis crossing the pond (pond cx=-6, sw=6 → spans x=-12 to x=0)
        // Bridge goes from x=-13 to x=1, centered at x=-6, z=-14
        let bridgeLen: Float = 14.5
        let deck = ModelEntity(mesh: .generateBox(width: bridgeLen, height: 0.15, depth: 1.6), materials: [woodMat])
        deck.position = [-6, 0.2, -14]
        content.add(deck)

        // Planks running across the width
        for i in 0..<10 {
            let plank = ModelEntity(mesh: .generateBox(width: bridgeLen, height: 0.08, depth: 0.12), materials: [railMat])
            plank.position = [-6, 0.28, -13.2 - Float(i) * 0.16]
            content.add(plank)
        }

        // Railings along both long sides
        for dz: Float in [-0.7, 0.7] {
            let rail = ModelEntity(mesh: .generateBox(width: bridgeLen, height: 0.08, depth: 0.08), materials: [railMat])
            rail.position = [-6, 0.65, -14 + dz]
            content.add(rail)

            for i in 0..<8 {
                let post = ModelEntity(mesh: .generateCylinder(height: 0.65, radius: 0.04), materials: [railMat])
                post.position = [-13 + Float(i) * 2.0, 0.4, -14 + dz]
                content.add(post)
            }
        }
    }

    // MARK: - Stepping Stones

    private func addSteppingStones(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: 0.56, green: 0.53, blue: 0.48, alpha: 1))

        let stones: [(Float, Float)] = [
            // Main path
            (0.2, -2), (-0.1, -4), (0.3, -6), (0, -8), (-0.2, -10),
            (0.1, -12), (0, -14), (0.2, -16), (-0.1, -18), (0, -20),
            // Right branch
            (2, -15), (4, -15.2), (6, -14.8), (8, -15), (10, -14.5),
            // Left branch
            (-2, -22), (-4, -22.2), (-6, -22), (-8, -21.8), (-10, -22),
            // Diagonal
            (-3, -26), (-5, -28), (-7, -30), (-8, -32),
        ]
        for s in stones {
            let stone = ModelEntity(mesh: .generateSphere(radius: 1), materials: [mat])
            stone.position = [s.0, 0.05, s.1]
            stone.scale = [0.42 + rng(Int(s.0*7+s.1))*0.2, 0.09, 0.38 + rng(Int(s.1*5))*0.18]
            content.add(stone)
        }
    }

    // MARK: - Cherry Trees

    private func addCherryTrees(to content: inout RealityViewContent) {
        let blossomColors: [UIColor] = [
            UIColor(red: 0.98, green: 0.72, blue: 0.80, alpha: 1),
            UIColor(red: 0.96, green: 0.80, blue: 0.87, alpha: 1),
            UIColor(red: 1.00, green: 0.88, blue: 0.91, alpha: 1),
            UIColor(red: 0.95, green: 0.68, blue: 0.76, alpha: 1),
        ]
        var trunkMat = UnlitMaterial()
        trunkMat.color = .init(tint: UIColor(red: 0.26, green: 0.16, blue: 0.10, alpha: 1))

        let trees: [(Float, Float, Float)] = [
            ( 3.5,  -5,  1.1), (-3.5,  -6,  1.0), ( 6.5, -10,  1.3),
            (-5.0, -11,  0.9), ( 2.0, -18,  1.0), (-7.5, -17,  1.2),
            ( 9.5,  -4,  0.8), (10.0, -19,  1.0), (-11,   -7,  1.1),
            (-10,  -22,  0.9), ( 5.0, -25,  1.2), (-4.5, -26,  1.0),
            (14.0, -13,  1.4), (-14,  -14,  1.3), ( 1.0, -30,  1.1),
            (-8,   -30,  1.0), (12.0, -26,  1.2), (-16,  -20,  1.0),
            ( 7.0, -33,  0.9), (-3,   -35,  1.1), ( 16,   -6,  1.0),
            (-18,   -8,  1.2), ( 4.0,  -2,  0.9), (-2,    -3,  0.8),
            (18.0, -18,  1.3), (-18,  -28,  1.1), ( 11,  -35,  1.0),
            (-12,  -35,  1.2), ( 0,   -38,  1.1), (8,    -22,  0.9),
            (-6,   -40,  1.0), (15,   -30,  1.2), (-15,  -32,  0.9),
            ( 3,   -42,  1.0), (-10,  -42,  1.1),
        ]

        let clusterOffsets: [(Float, Float, Float)] = [
            (0, 0, 0), (-0.7, 0.4, 0.2), (0.7, 0.3, -0.2),
            (0.2, 0.6, 0.5), (-0.4, 0.5, -0.4), (0.5, 0.2, 0.6),
            (-0.3, 0.7, 0.3), (0.4, 0.8, -0.5),
        ]

        for (i, t) in trees.enumerated() {
            let s = t.2
            let trunkH = 2.0 * s

            let trunk = ModelEntity(mesh: .generateCylinder(height: trunkH, radius: 0.13 * s), materials: [trunkMat])
            trunk.position = [t.0, trunkH / 2, t.1]
            content.add(trunk)

            // Two angled branches
            for (bx, ba): (Float, Float) in [(-0.5, 0.4), (0.45, -0.35)] {
                let branch = ModelEntity(mesh: .generateCylinder(height: 1.1 * s, radius: 0.07 * s), materials: [trunkMat])
                branch.position = [t.0 + bx * s, trunkH + 0.25 * s, t.1]
                branch.orientation = simd_quatf(angle: ba, axis: [0, 0, 1])
                content.add(branch)
            }

            let color = blossomColors[i % blossomColors.count]
            var blossomMat = UnlitMaterial()
            blossomMat.color = .init(tint: color)
            let canopyY: Float = trunkH + 1.1 * s

            for off in clusterOffsets {
                let blossom = ModelEntity(mesh: .generateSphere(radius: 1.05 * s), materials: [blossomMat])
                blossom.position = [t.0 + off.0 * s, canopyY + off.1 * s, t.1 + off.2 * s]
                content.add(blossom)
            }
        }
    }

    // MARK: - Evergreens

    private func addEvergreens(to content: inout RealityViewContent) {
        var darkMat = UnlitMaterial()
        darkMat.color = .init(tint: UIColor(red: 0.12, green: 0.28, blue: 0.14, alpha: 1))
        var trunkMat = UnlitMaterial()
        trunkMat.color = .init(tint: UIColor(red: 0.28, green: 0.18, blue: 0.10, alpha: 1))

        let positions: [(Float, Float, Float)] = [
            ( 12, -8,  1.0), (-13, -10, 1.1), (17, -22, 0.9),
            (-17, -18, 1.0), ( 8,  -28, 1.2), (-9, -32, 0.8),
            ( 14, -38, 1.0), (-14, -38, 1.1), (20, -12, 0.9),
            (-20, -12, 1.0),
        ]
        for t in positions {
            let s = t.2
            let trunk = ModelEntity(mesh: .generateCylinder(height: 1.5 * s, radius: 0.10 * s), materials: [trunkMat])
            trunk.position = [t.0, 0.75 * s, t.1]
            content.add(trunk)

            for (tier, h, r): (Float, Float, Float) in [(0, 2.0, 0.9), (0.9, 1.5, 0.65), (1.7, 1.0, 0.40)] {
                let cone = ModelEntity(mesh: .generateCone(height: h * s, radius: r * s), materials: [darkMat])
                cone.position = [t.0, 1.5 * s + tier * s, t.1]
                content.add(cone)
            }
        }
    }

    // MARK: - Petals

    private func addPetals(to content: inout RealityViewContent) {
        let petalColors: [UIColor] = [
            UIColor(red: 0.99, green: 0.80, blue: 0.85, alpha: 1),
            UIColor(red: 1.00, green: 0.88, blue: 0.90, alpha: 1),
            UIColor(white: 1.0, alpha: 1),
        ]
        // Floating petals
        for i in 0..<300 {
            var mat = UnlitMaterial()
            mat.color = .init(tint: petalColors[i % petalColors.count])
            let size = 0.035 + rng(i*4+3) * 0.07
            let petal = ModelEntity(mesh: .generateSphere(radius: size), materials: [mat])
            petal.position = [(rng(i*4)-0.5)*44, rng(i*4+1)*5.0, -(rng(i*4+2)*44)]
            petal.scale = [1.0, 0.25, 1.3]
            content.add(petal)
        }
        // Ground petal drifts
        for i in 0..<15 {
            var mat = UnlitMaterial()
            mat.color = .init(tint: petalColors[i % petalColors.count])
            let drift = ModelEntity(mesh: .generateSphere(radius: 1), materials: [mat])
            drift.position = [(rng(i*6)-0.5)*30, 0.03, -(2 + rng(i*6+1)*35)]
            drift.scale = [0.8 + rng(i*6+2)*1.2, 0.04, 0.6 + rng(i*6+3)*1.0]
            content.add(drift)
        }
    }

    // MARK: - Flower Bushes

    private func addFlowerBushes(to content: inout RealityViewContent) {
        let bushColors: [UIColor] = [
            UIColor(red: 0.95, green: 0.50, blue: 0.65, alpha: 1),  // pink
            UIColor(red: 0.98, green: 0.90, blue: 0.92, alpha: 1),  // white
            UIColor(red: 0.80, green: 0.15, blue: 0.20, alpha: 1),  // red
            UIColor(red: 0.90, green: 0.75, blue: 0.20, alpha: 1),  // yellow
            UIColor(red: 0.55, green: 0.28, blue: 0.70, alpha: 1),  // purple
        ]
        let positions: [(Float, Float)] = [
            ( 1.5, -4), (-1.5, -4), (3, -9), (-3, -9), (2, -14),
            (-2, -14), (4, -20), (-4, -20), (6, -24), (-6, -24),
            (8, -10), (-8, -12), (10, -28), (-10, -28), (5, -32),
            (-5, -32), (12, -16), (-12, -18), (3, -36), (-3, -36),
            (7, -6), (-7, -6), (11, -22), (-11, -22), (2, -40),
            (-8, -38), (14, -32), (-14, -30), (6, -42), (-6, -42),
        ]
        for (i, pos) in positions.enumerated() {
            var mat = UnlitMaterial()
            mat.color = .init(tint: bushColors[i % bushColors.count])
            let s = 0.25 + rng(i*3) * 0.25
            // Bush cluster (3 spheres)
            for j in 0..<3 {
                let bush = ModelEntity(mesh: .generateSphere(radius: s), materials: [mat])
                bush.position = [pos.0 + (rng(i*3+j)-0.5)*0.4, s*0.8, pos.1 + (rng(i*3+j+1)-0.5)*0.4]
                content.add(bush)
            }
        }
    }

    // MARK: - Torii Gates

    private func addToriiGates(to content: inout RealityViewContent) {
        func addTorii(x: Float, z: Float, scale: Float, angle: Float = 0) {
            var redMat = UnlitMaterial()
            redMat.color = .init(tint: UIColor(red: 0.80, green: 0.12, blue: 0.08, alpha: 1))
            var darkRed = UnlitMaterial()
            darkRed.color = .init(tint: UIColor(red: 0.52, green: 0.07, blue: 0.04, alpha: 1))

            let s = scale
            let pillarH = 5.5 * s
            let span: Float = 2.0 * s

            for dx: Float in [-span, span] {
                let pillar = ModelEntity(mesh: .generateCylinder(height: pillarH, radius: 0.22 * s), materials: [redMat])
                pillar.position = [x + dx, pillarH/2, z]
                pillar.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])
                content.add(pillar)

                let base = ModelEntity(mesh: .generateBox(width: 0.6*s, height: 0.4*s, depth: 0.6*s), materials: [darkRed])
                base.position = [x + dx, 0.2*s, z]
                content.add(base)
            }

            // Kasagi
            let kasagi = ModelEntity(mesh: .generateBox(width: (span*2+1.4)*s, height: 0.35*s, depth: 0.45*s), materials: [redMat])
            kasagi.position = [x, pillarH + 0.15*s, z]
            content.add(kasagi)

            // Kasagi upturns
            for dx: Float in [-(span+0.5)*s, (span+0.5)*s] {
                let up = ModelEntity(mesh: .generateBox(width: 0.45*s, height: 0.25*s, depth: 0.45*s), materials: [redMat])
                up.position = [x + dx, pillarH + 0.28*s, z]
                content.add(up)
            }

            // Shimagi
            let shimagi = ModelEntity(mesh: .generateBox(width: span*2.0*s, height: 0.22*s, depth: 0.30*s), materials: [darkRed])
            shimagi.position = [x, pillarH - 0.7*s, z]
            content.add(shimagi)

            // Nuki
            let nuki = ModelEntity(mesh: .generateBox(width: span*1.8*s, height: 0.20*s, depth: 0.25*s), materials: [darkRed])
            nuki.position = [x, pillarH*0.55, z]
            content.add(nuki)
        }

        addTorii(x:  0, z: -22, scale: 1.0)          // main entrance
        addTorii(x:  5, z: -10, scale: 0.7)           // inner right gate
        addTorii(x: -8, z: -34, scale: 0.85, angle: 0.3)  // diagonal path gate
    }

    // MARK: - Lanterns

    private func addLanterns(to content: inout RealityViewContent) {
        var stoneMat = UnlitMaterial()
        stoneMat.color = .init(tint: UIColor(red: 0.56, green: 0.53, blue: 0.48, alpha: 1))
        var glowMat = UnlitMaterial()
        glowMat.color = .init(tint: UIColor(red: 1.0, green: 0.88, blue: 0.55, alpha: 1))

        let positions: [(Float, Float)] = [
            // Flanking main torii
            ( 2.5, -22), (-2.5, -22),
            // Flanking inner torii
            ( 3.5, -10), ( 6.5, -10),
            // Flanking diagonal torii
            (-6, -34), (-10, -34),
            // Lining main path both sides
            ( 1.5,  -5), (-1.5,  -5),
            ( 1.5, -12), (-1.5, -12),
            ( 1.5, -18), (-1.5, -18),
            ( 1.5, -28), (-1.5, -28),
            // Around main pond
            (-2, -14), (-10, -14), (-6, -10), (-6, -20),
            // Around second pond
            ( 7, -20), (11, -20),
        ]

        for pos in positions {
            let bx = pos.0, bz = pos.1
            let base = ModelEntity(mesh: .generateCylinder(height: 0.3, radius: 0.32), materials: [stoneMat])
            base.position = [bx, 0.15, bz]; content.add(base)
            let shaft = ModelEntity(mesh: .generateCylinder(height: 1.0, radius: 0.11), materials: [stoneMat])
            shaft.position = [bx, 0.8, bz]; content.add(shaft)
            let mid = ModelEntity(mesh: .generateBox(width: 0.40, height: 0.16, depth: 0.40), materials: [stoneMat])
            mid.position = [bx, 1.38, bz]; content.add(mid)
            let box = ModelEntity(mesh: .generateBox(width: 0.36, height: 0.40, depth: 0.36), materials: [glowMat])
            box.position = [bx, 1.72, bz]; content.add(box)
            let roof = ModelEntity(mesh: .generateBox(width: 0.52, height: 0.09, depth: 0.52), materials: [stoneMat])
            roof.position = [bx, 1.96, bz]; content.add(roof)
            let cap = ModelEntity(mesh: .generateCone(height: 0.20, radius: 0.26), materials: [stoneMat])
            cap.position = [bx, 2.12, bz]; content.add(cap)
        }
    }

    // MARK: - Bamboo Fence

    private func addBambooFence(to content: inout RealityViewContent) {
        var bamMat = UnlitMaterial()
        bamMat.color = .init(tint: UIColor(red: 0.50, green: 0.56, blue: 0.26, alpha: 1))
        var ropeMat = UnlitMaterial()
        ropeMat.color = .init(tint: UIColor(red: 0.42, green: 0.32, blue: 0.20, alpha: 1))

        func fenceRow(start: SIMD3<Float>, end: SIMD3<Float>, count: Int) {
            for i in 0..<count {
                let t = Float(i) / Float(count - 1)
                let pos = start + (end - start) * t
                let post = ModelEntity(mesh: .generateCylinder(height: 1.4, radius: 0.065), materials: [bamMat])
                post.position = pos + [0, 0.7, 0]
                content.add(post)
            }
            let mid = (start + end) / 2
            let len = simd_length(end - start)
            let dir = simd_normalize(end - start)
            for ry: Float in [0.5, 1.0] {
                let rail = ModelEntity(mesh: .generateCylinder(height: len, radius: 0.04), materials: [ropeMat])
                rail.position = mid + [0, ry, 0]
                rail.orientation = simd_quatf(from: [0, 1, 0], to: dir)
                content.add(rail)
            }
        }

        // Four sides
        fenceRow(start: [-22,0, 3], end: [ 22,0,  3], count: 20) // front
        fenceRow(start: [-22,0,-45], end: [ 22,0,-45], count: 20) // back
        fenceRow(start: [-22,0, 3], end: [-22,0,-45], count: 22) // left
        fenceRow(start: [ 22,0, 3], end: [ 22,0,-45], count: 22) // right
    }

    // MARK: - Pagoda

    private func addPagoda(to content: inout RealityViewContent) {
        var wallMat = UnlitMaterial()
        wallMat.color = .init(tint: UIColor(red: 0.55, green: 0.20, blue: 0.08, alpha: 1))
        var roofMat = UnlitMaterial()
        roofMat.color = .init(tint: UIColor(red: 0.20, green: 0.28, blue: 0.18, alpha: 1))
        var stoneMat = UnlitMaterial()
        stoneMat.color = .init(tint: UIColor(red: 0.55, green: 0.52, blue: 0.46, alpha: 1))

        let px: Float = 0, pz: Float = -40
        // Stone base platform
        let platform = ModelEntity(mesh: .generateBox(width: 5, height: 0.5, depth: 5), materials: [stoneMat])
        platform.position = [px, 0.25, pz]; content.add(platform)

        // 5 tiers — each smaller and higher
        let tiers: [(Float, Float)] = [(3.6,1.4),(2.9,1.2),(2.3,1.0),(1.8,0.9),(1.3,0.8)]
        var y: Float = 0.5
        for (i, tier) in tiers.enumerated() {
            let w = tier.0, h = tier.1
            let wall = ModelEntity(mesh: .generateBox(width: w, height: h, depth: w), materials: [wallMat])
            wall.position = [px, y + h/2, pz]; content.add(wall)
            y += h

            // Roof eave (wider flat box)
            let eave = ModelEntity(mesh: .generateBox(width: w + 1.2, height: 0.18, depth: w + 1.2), materials: [roofMat])
            eave.position = [px, y + 0.09, pz]; content.add(eave)

            // Upturned corners
            for cx: Float in [-(w/2+0.5), (w/2+0.5)] {
                for cz: Float in [-(w/2+0.5), (w/2+0.5)] {
                    let corner = ModelEntity(mesh: .generateBox(width: 0.25, height: 0.18, depth: 0.25), materials: [roofMat])
                    corner.position = [px+cx, y+0.22, pz+cz]; content.add(corner)
                }
            }
            y += 0.28

            if i < tiers.count - 1 { y += 0.1 }
        }

        // Spire
        let spire = ModelEntity(mesh: .generateCylinder(height: 1.5, radius: 0.08), materials: [wallMat])
        spire.position = [px, y + 0.75, pz]; content.add(spire)
        let finial = ModelEntity(mesh: .generateSphere(radius: 0.18), materials: [roofMat])
        finial.position = [px, y + 1.5, pz]; content.add(finial)
    }

    // MARK: - Rock Garden

    private func addRockGarden(to content: inout RealityViewContent) {
        // Raked gravel section near pagoda
        var gravelMat = UnlitMaterial()
        gravelMat.color = .init(tint: UIColor(red: 0.80, green: 0.76, blue: 0.68, alpha: 1))
        let gravel = ModelEntity(mesh: .generateBox(width: 10, height: 0.06, depth: 8), materials: [gravelMat])
        gravel.position = [8, 0.02, -38]; content.add(gravel)

        // Rake lines
        var rakeMat = UnlitMaterial()
        rakeMat.color = .init(tint: UIColor(red: 0.68, green: 0.64, blue: 0.56, alpha: 1))
        for i in 0..<8 {
            let line = ModelEntity(mesh: .generateBox(width: 10, height: 0.04, depth: 0.08), materials: [rakeMat])
            line.position = [8, 0.05, -35 - Float(i) * 0.9]
            content.add(line)
        }

        // Zen rocks
        var stoneMat = UnlitMaterial()
        stoneMat.color = .init(tint: UIColor(red: 0.45, green: 0.43, blue: 0.40, alpha: 1))
        let rocks: [(Float, Float, Float, Float, Float)] = [
            (6, -36, 1.2, 0.9, 1.0), (10, -39, 0.7, 0.6, 0.8),
            (8,  -41, 1.4, 1.0, 1.2), (5, -40, 0.5, 0.4, 0.6),
            (11, -37, 0.9, 0.7, 0.8), (9, -35, 0.6, 0.5, 0.7),
        ]
        for r in rocks {
            let rock = ModelEntity(mesh: .generateSphere(radius: 1), materials: [stoneMat])
            rock.position = [r.0, 0.3, r.1]; rock.scale = [r.2, r.3, r.4]; content.add(rock)
        }
    }
}
