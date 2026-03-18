//
//  CyberpunkCity.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit
import UIKit

struct CyberpunkCity: SceneContent {
    func build(content: inout RealityViewContent) async {
        addSky(to: &content)
        addGround(to: &content)
        addBuildings(to: &content)
        addDistantSkyline(to: &content)
        addNeonSigns(to: &content)
        addStreetDetails(to: &content)
        addAtmosphere(to: &content)
        addRain(to: &content)
        addFlyingVehicles(to: &content)
        addPowerLines(to: &content)
    }

    private func rng(_ seed: Int) -> Float {
        let x = sin(Float(seed) * 127.1 + 311.7) * 43758.5
        return x - floor(x)
    }

    // MARK: - Sky

    private func addSky(to content: inout RealityViewContent) {
        var skyMat = UnlitMaterial()
        skyMat.color = .init(tint: UIColor(red: 0.03, green: 0.02, blue: 0.06, alpha: 1))
        skyMat.faceCulling = .front
        content.add(ModelEntity(mesh: .generateSphere(radius: 500), materials: [skyMat]))

        var purpleMat = UnlitMaterial()
        purpleMat.color = .init(tint: UIColor(red: 0.22, green: 0.04, blue: 0.30, alpha: 1))
        let purpleSmog = ModelEntity(mesh: .generateSphere(radius: 1), materials: [purpleMat])
        purpleSmog.scale = [1000, 28, 1000]; purpleSmog.position = [0, -28, 0]
        content.add(purpleSmog)

        var cyanMat = UnlitMaterial()
        cyanMat.color = .init(tint: UIColor(red: 0.02, green: 0.15, blue: 0.24, alpha: 1))
        let cyanSmog = ModelEntity(mesh: .generateSphere(radius: 1), materials: [cyanMat])
        cyanSmog.scale = [1000, 16, 1000]; cyanSmog.position = [0, -16, 0]
        content.add(cyanSmog)

        // Warm orange city-glow behind viewer
        var orangeMat = UnlitMaterial()
        orangeMat.color = .init(tint: UIColor(red: 0.35, green: 0.12, blue: 0.04, alpha: 1))
        let orangeGlow = ModelEntity(mesh: .generateSphere(radius: 1), materials: [orangeMat])
        orangeGlow.scale = [1000, 10, 1000]; orangeGlow.position = [0, -40, 60]
        content.add(orangeGlow)

        // Moon
        var moonMat = UnlitMaterial()
        moonMat.color = .init(tint: UIColor(red: 0.88, green: 0.86, blue: 0.80, alpha: 1))
        let moon = ModelEntity(mesh: .generateSphere(radius: 4), materials: [moonMat])
        moon.position = [-80, 120, -300]; content.add(moon)

        var moonHaloMat = UnlitMaterial()
        moonHaloMat.color = .init(tint: UIColor(red: 0.65, green: 0.63, blue: 0.60, alpha: 1))
        moonHaloMat.faceCulling = .front
        let moonHalo = ModelEntity(mesh: .generateSphere(radius: 7), materials: [moonHaloMat])
        moonHalo.position = [-80, 120, -300]; content.add(moonHalo)
    }

    // MARK: - Ground

    private func addGround(to content: inout RealityViewContent) {
        // Wide base pavement
        var paveMat = UnlitMaterial()
        paveMat.color = .init(tint: UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1))
        let ground = ModelEntity(mesh: .generateBox(width: 200, height: 0.1, depth: 200), materials: [paveMat])
        ground.position = [0, -0.06, -90]; content.add(ground)

        // Central road - slightly different tone
        var roadMat = UnlitMaterial()
        roadMat.color = .init(tint: UIColor(red: 0.08, green: 0.08, blue: 0.11, alpha: 1))
        let road = ModelEntity(mesh: .generateBox(width: 10, height: 0.1, depth: 200), materials: [roadMat])
        road.position = [0, -0.04, -90]; content.add(road)

        // Sidewalks - raised
        var swMat = UnlitMaterial()
        swMat.color = .init(tint: UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1))
        for sx: Float in [-7.5, 7.5] {
            let sw = ModelEntity(mesh: .generateBox(width: 5, height: 0.16, depth: 200), materials: [swMat])
            sw.position = [sx, 0.02, -90]; content.add(sw)
        }

        // Curbs
        var curbMat = UnlitMaterial()
        curbMat.color = .init(tint: UIColor(red: 0.20, green: 0.20, blue: 0.25, alpha: 1))
        for cx: Float in [-5.1, 5.1] {
            let curb = ModelEntity(mesh: .generateBox(width: 0.2, height: 0.22, depth: 200), materials: [curbMat])
            curb.position = [cx, 0.06, -90]; content.add(curb)
        }

        // Lane markings
        var markMat = UnlitMaterial()
        markMat.color = .init(tint: UIColor(red: 0.22, green: 0.22, blue: 0.28, alpha: 1))
        for i in 0..<20 {
            let mark = ModelEntity(mesh: .generateBox(width: 0.12, height: 0.07, depth: 2.5), materials: [markMat])
            mark.position = [0, 0.04, -3 - Float(i) * 5]; content.add(mark)
        }

        // Puddles
        let puddleColors: [UIColor] = [
            UIColor(red: 0.80, green: 0.05, blue: 0.60, alpha: 1),
            UIColor(red: 0.00, green: 0.70, blue: 0.90, alpha: 1),
            UIColor(red: 0.90, green: 0.60, blue: 0.00, alpha: 1),
            UIColor(red: 0.60, green: 0.00, blue: 0.90, alpha: 1),
            UIColor(red: 0.00, green: 0.90, blue: 0.50, alpha: 1),
        ]
        let puddles: [(Float, Float, Float, Float)] = [
            (-3,-4,2.5,1.2),(4,-8,1.8,0.9),(-5,-12,3.0,1.5),(2,-16,2.0,1.0),
            (-2,-3,1.5,0.8),(6,-6,2.2,1.1),(-7,-9,1.8,0.9),(3,-14,2.5,1.3),
            (-4,-18,1.6,0.8),(0,-5,1.2,2.0),(-1,-22,1.4,0.7),(5,-25,2.0,1.2),
            (-6,-28,1.6,0.9),(2,-30,1.8,1.0),(-3,-35,2.2,1.4),
        ]
        for (i, p) in puddles.enumerated() {
            var mat = UnlitMaterial()
            mat.color = .init(tint: puddleColors[i % puddleColors.count])
            let puddle = ModelEntity(mesh: .generateSphere(radius: 1), materials: [mat])
            puddle.position = [p.0, 0.03, p.1]; puddle.scale = [p.2, 0.025, p.3]
            content.add(puddle)
        }

        // Manhole covers with steam glow
        var manholeMat = UnlitMaterial()
        manholeMat.color = .init(tint: UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1))
        var steamMat = UnlitMaterial()
        steamMat.color = .init(tint: UIColor(red: 0.60, green: 0.30, blue: 0.00, alpha: 1))
        for pos: (Float, Float) in [(0,-8),(-1,-20),(1,-35)] {
            let cover = ModelEntity(mesh: .generateCylinder(height: 0.05, radius: 0.45), materials: [manholeMat])
            cover.position = [pos.0, 0.04, pos.1]; content.add(cover)
            let steam = ModelEntity(mesh: .generateCylinder(height: 0.02, radius: 0.32), materials: [steamMat])
            steam.position = [pos.0, 0.06, pos.1]; content.add(steam)
        }
    }

    // MARK: - Buildings

    private func addBuildings(to content: inout RealityViewContent) {
        struct Bldg {
            let x,z,w,d,baseH,towerH,towerS: Float
        }
        let buildings: [Bldg] = [
            Bldg(x:-14,z: -8,w: 9,d:12,baseH: 65,towerH:30,towerS:0.55),
            Bldg(x:-16,z:-25,w:11,d:12,baseH: 95,towerH:40,towerS:0.60),
            Bldg(x:-14,z:-45,w: 9,d:12,baseH: 70,towerH: 0,towerS:0),
            Bldg(x:-17,z:-15,w: 8,d:10,baseH: 88,towerH:35,towerS:0.50),
            Bldg(x:-15,z:-35,w:10,d:12,baseH: 80,towerH:28,towerS:0.65),
            Bldg(x:-13,z:-58,w:10,d:11,baseH: 55,towerH:20,towerS:0.55),
            Bldg(x: 14,z: -8,w: 9,d:12,baseH: 75,towerH:35,towerS:0.55),
            Bldg(x: 16,z:-25,w:11,d:12,baseH:105,towerH:45,towerS:0.60),
            Bldg(x: 14,z:-45,w: 9,d:12,baseH: 72,towerH:22,towerS:0.50),
            Bldg(x: 17,z:-15,w: 8,d:10,baseH: 92,towerH:38,towerS:0.55),
            Bldg(x: 15,z:-35,w:10,d:12,baseH: 78,towerH:30,towerS:0.65),
            Bldg(x: 13,z:-58,w:10,d:11,baseH: 60,towerH:25,towerS:0.55),
            Bldg(x: -8,z: 14,w:12,d:10,baseH: 65,towerH:20,towerS:0.60),
            Bldg(x:  0,z: 16,w:14,d:10,baseH: 98,towerH:40,towerS:0.55),
            Bldg(x:  8,z: 14,w:12,d:10,baseH: 75,towerH:28,towerS:0.60),
            Bldg(x:-24,z: -5,w: 8,d: 8,baseH:120,towerH:50,towerS:0.50),
            Bldg(x: 24,z: -5,w: 8,d: 8,baseH:115,towerH:45,towerS:0.50),
            Bldg(x:  0,z:-68,w:30,d:15,baseH: 85,towerH: 0,towerS:0),
            Bldg(x:-22,z:-48,w:10,d:10,baseH: 90,towerH:35,towerS:0.55),
            Bldg(x: 22,z:-48,w:10,d:10,baseH: 95,towerH:40,towerS:0.55),
        ]

        let bldgColors: [UIColor] = [
            UIColor(red:0.07,green:0.07,blue:0.10,alpha:1),
            UIColor(red:0.09,green:0.07,blue:0.13,alpha:1),
            UIColor(red:0.06,green:0.09,blue:0.11,alpha:1),
            UIColor(red:0.11,green:0.07,blue:0.09,alpha:1),
            UIColor(red:0.08,green:0.08,blue:0.08,alpha:1),
        ]
        let winColors: [UIColor] = [
            UIColor(red:0.00,green:0.70,blue:0.85,alpha:1),
            UIColor(red:0.85,green:0.75,blue:0.50,alpha:1),
            UIColor(red:0.70,green:0.00,blue:0.80,alpha:1),
            UIColor(red:0.90,green:0.35,blue:0.00,alpha:1),
        ]
        let neonTrimColors: [UIColor] = [
            UIColor(red:1.0,green:0.05,blue:0.55,alpha:1),
            UIColor(red:0.00,green:0.85,blue:1.0,alpha:1),
            UIColor(red:0.90,green:0.20,blue:1.0,alpha:1),
        ]

        for (i, b) in buildings.enumerated() {
            var mat = UnlitMaterial()
            mat.color = .init(tint: bldgColors[i % bldgColors.count])

            // Base
            let base = ModelEntity(mesh: .generateBox(width: b.w, height: b.baseH, depth: b.d), materials: [mat])
            base.position = [b.x, b.baseH/2, b.z]; content.add(base)

            // Setback tower
            if b.towerH > 0 {
                let tw = b.w * b.towerS, td = b.d * b.towerS
                var tMat = UnlitMaterial()
                tMat.color = .init(tint: bldgColors[(i+2) % bldgColors.count])
                let tower = ModelEntity(mesh: .generateBox(width: tw, height: b.towerH, depth: td), materials: [tMat])
                tower.position = [b.x, b.baseH + b.towerH/2, b.z]; content.add(tower)

                // Tower windows
                for row in 0..<Int(b.towerH/5) {
                    if rng(row*17+i*11) > 0.4 {
                        var wm = UnlitMaterial()
                        wm.color = .init(tint: winColors[(row+i+2) % winColors.count])
                        let face: Float = b.x < 0 ? td/2+0.08 : -(td/2+0.08)
                        let win = ModelEntity(mesh: .generateBox(width: tw*0.7, height: 1.8, depth: 0.1), materials: [wm])
                        win.position = [b.x, b.baseH+3+Float(row)*5, b.z+face]; content.add(win)
                    }
                }

                // Antenna + warning light
                var antMat = UnlitMaterial()
                antMat.color = .init(tint: UIColor(red:0.45,green:0.45,blue:0.50,alpha:1))
                let ant = ModelEntity(mesh: .generateCylinder(height: 4, radius: 0.07), materials: [antMat])
                ant.position = [b.x, b.baseH+b.towerH+2, b.z]; content.add(ant)
                var redMat = UnlitMaterial()
                redMat.color = .init(tint: UIColor(red:1.0,green:0.05,blue:0.05,alpha:1))
                let warn = ModelEntity(mesh: .generateSphere(radius: 0.14), materials: [redMat])
                warn.position = [b.x, b.baseH+b.towerH+4.2, b.z]; content.add(warn)
            }

            // Base windows
            for row in 0..<Int(b.baseH/5) {
                if rng(row*13+i*7) > 0.45 {
                    var wm = UnlitMaterial()
                    wm.color = .init(tint: winColors[(row+i) % winColors.count])
                    let face: Float = b.x < 0 ? b.d/2+0.08 : -(b.d/2+0.08)
                    let win = ModelEntity(mesh: .generateBox(width: b.w*0.72, height: 1.8, depth: 0.10), materials: [wm])
                    win.position = [b.x, 4+Float(row)*5, b.z+face]; content.add(win)
                }
            }

            // Fire escapes on close buildings
            if abs(b.x) < 20 && abs(b.z) < 62 && b.baseH > 20 {
                var feMat = UnlitMaterial()
                feMat.color = .init(tint: UIColor(red:0.18,green:0.18,blue:0.22,alpha:1))
                let face: Float = b.x < 0 ? b.d/2+0.15 : -(b.d/2+0.15)
                let numFloors = Int(min(b.baseH, 40)/4)
                for floor in 1..<numFloors {
                    let platform = ModelEntity(mesh: .generateBox(width: 2.5, height: 0.10, depth: 1.2), materials: [feMat])
                    platform.position = [b.x, Float(floor)*4, b.z+face]; content.add(platform)
                }
                let railH = Float(numFloors-1)*4
                let rail = ModelEntity(mesh: .generateBox(width: 0.06, height: railH, depth: 0.06), materials: [feMat])
                rail.position = [b.x+(b.x<0 ? -1.1:1.1), railH/2+4, b.z+face]; content.add(rail)
            }

            // Neon base trim + mid trim
            if abs(b.x) < 22 && i%3 != 0 {
                var trimMat = UnlitMaterial()
                trimMat.color = .init(tint: neonTrimColors[i % neonTrimColors.count])
                let face: Float = b.x < 0 ? b.d/2+0.06 : -(b.d/2+0.06)
                let baseTrim = ModelEntity(mesh: .generateBox(width: b.w*0.9, height: 0.20, depth: 0.10), materials: [trimMat])
                baseTrim.position = [b.x, 0.5, b.z+face]; content.add(baseTrim)
                if rng(i*3) > 0.5 {
                    let midTrim = ModelEntity(mesh: .generateBox(width: b.w*0.9, height: 0.15, depth: 0.10), materials: [trimMat])
                    midTrim.position = [b.x, b.baseH*0.4, b.z+face]; content.add(midTrim)
                }
            }

            // Rooftop AC units on flat-top buildings
            if b.towerH == 0 {
                var acMat = UnlitMaterial()
                acMat.color = .init(tint: UIColor(red:0.22,green:0.22,blue:0.26,alpha:1))
                for j in 0..<3 {
                    let ac = ModelEntity(mesh: .generateBox(width: 1.2, height: 0.8, depth: 0.9), materials: [acMat])
                    ac.position = [b.x+(rng(i*4+j)-0.5)*b.w*0.7, b.baseH+0.4, b.z+(rng(i*4+j+1)-0.5)*b.d*0.6]
                    content.add(ac)
                }
            }
        }

        // Water towers
        let waterTowers: [(Float, Float, Float)] = [(-14,75,-8),(14,110,-25),(-16,95,-35)]
        for wt in waterTowers {
            var wtMat = UnlitMaterial()
            wtMat.color = .init(tint: UIColor(red:0.28,green:0.22,blue:0.16,alpha:1))
            let tank = ModelEntity(mesh: .generateCylinder(height: 2.5, radius: 1.2), materials: [wtMat])
            tank.position = [wt.0, wt.1, wt.2]; content.add(tank)
            let legs = ModelEntity(mesh: .generateBox(width: 1.8, height: 3.0, depth: 1.8), materials: [wtMat])
            legs.position = [wt.0, wt.1-2.8, wt.2]; content.add(legs)
        }
    }

    // MARK: - Distant Skyline

    private func addDistantSkyline(to content: inout RealityViewContent) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red:0.05,green:0.05,blue:0.08,alpha:1))
        var dimWin = UnlitMaterial()
        dimWin.color = .init(tint: UIColor(red:0.00,green:0.30,blue:0.45,alpha:1))

        let far: [(Float,Float,Float,Float,Float)] = [
            (-40,-90,20,15,80),(-15,-90,18,15,110),(10,-90,20,15,95),(35,-90,18,15,85),
            (-60,-80,16,12,70),(55,-80,16,12,75),
            (-40,-20,14,12,90),(-38,-40,16,12,120),(-40,-60,14,12,80),(-50,-10,12,12,100),(-50,-50,14,12,95),
            (40,-20,14,12,85),(38,-40,16,12,115),(40,-60,14,12,75),(50,-10,12,12,105),(50,-50,14,12,90),
        ]
        for (bx,bz,bw,bd,bh) in far {
            let b = ModelEntity(mesh: .generateBox(width: bw, height: bh, depth: bd), materials: [mat])
            b.position = [bx, bh/2, bz]; content.add(b)
            let win = ModelEntity(mesh: .generateBox(width: bw*0.55, height: bh*0.5, depth: 0.5), materials: [dimWin])
            win.position = [bx, bh*0.5, bz+bd/2+0.3]; content.add(win)
        }
    }

    // MARK: - Neon Signs

    private func addNeonSigns(to content: inout RealityViewContent) {
        struct Sign { let x,y,z,w,h: Float; let vertical: Bool; let color: UIColor }
        let signs: [Sign] = [
            Sign(x:-10,y:12,z: -8,w:6.5,h:2.5,vertical:false,color:UIColor(red:1.0,green:0.05,blue:0.55,alpha:1)),
            Sign(x: 10,y:15,z:-10,w:5.5,h:2.0,vertical:false,color:UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            Sign(x: -9,y:22,z:-20,w:7.5,h:3.0,vertical:false,color:UIColor(red:1.0,green:0.80,blue:0.00,alpha:1)),
            Sign(x: 11,y:18,z:-25,w:5.5,h:2.2,vertical:false,color:UIColor(red:0.55,green:1.0,blue:0.10,alpha:1)),
            Sign(x:-11,y:30,z:-30,w:8.5,h:3.5,vertical:false,color:UIColor(red:1.0,green:0.05,blue:0.55,alpha:1)),
            Sign(x: 12,y:28,z:-35,w:6.5,h:2.8,vertical:false,color:UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            Sign(x: -8,y:42,z:-15,w:9.5,h:4.0,vertical:false,color:UIColor(red:0.90,green:0.20,blue:1.0,alpha:1)),
            Sign(x: 10,y:35,z:-45,w:7.5,h:3.0,vertical:false,color:UIColor(red:1.0,green:0.55,blue:0.00,alpha:1)),
            Sign(x: -9,y:52,z:-25,w:7.5,h:3.2,vertical:false,color:UIColor(red:0.00,green:1.0,blue:0.60,alpha:1)),
            Sign(x: 11,y:55,z:-18,w:8.5,h:3.5,vertical:false,color:UIColor(red:1.0,green:0.05,blue:0.55,alpha:1)),
            Sign(x: -9,y:65,z:-35,w:6.5,h:2.8,vertical:false,color:UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            Sign(x: 10,y:70,z:-28,w:7.5,h:3.0,vertical:false,color:UIColor(red:1.0,green:0.80,blue:0.00,alpha:1)),
            // Large end-of-alley billboard
            Sign(x:  0,y:30,z:-67,w:22,h:12,vertical:false,color:UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            // Vertical signs
            Sign(x:-10,y:18,z:-14,w:1.4,h:8,vertical:true,color:UIColor(red:1.0,green:0.05,blue:0.55,alpha:1)),
            Sign(x: 10,y:20,z:-18,w:1.4,h:9,vertical:true,color:UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            Sign(x:-10,y:32,z:-38,w:1.2,h:7,vertical:true,color:UIColor(red:1.0,green:0.80,blue:0.00,alpha:1)),
            Sign(x: 11,y:28,z:-42,w:1.2,h:8,vertical:true,color:UIColor(red:0.90,green:0.20,blue:1.0,alpha:1)),
            // Street-level shop signs
            Sign(x: -9,y:4,z: -6,w:3.0,h:1.2,vertical:false,color:UIColor(red:0.00,green:0.90,blue:0.60,alpha:1)),
            Sign(x: 10,y:4,z:-12,w:2.5,h:1.0,vertical:false,color:UIColor(red:1.0,green:0.55,blue:0.00,alpha:1)),
            Sign(x: -9,y:4,z:-22,w:3.5,h:1.2,vertical:false,color:UIColor(red:0.90,green:0.20,blue:1.0,alpha:1)),
            Sign(x: 10,y:4,z:-30,w:3.0,h:1.0,vertical:false,color:UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
        ]

        for s in signs {
            var mat = UnlitMaterial()
            mat.color = .init(tint: s.color)
            let panel = ModelEntity(mesh: .generateBox(width: s.w, height: s.h, depth: 0.18), materials: [mat])
            panel.position = [s.x, s.y, s.z]
            if s.vertical { panel.orientation = simd_quatf(angle: .pi/2, axis: [0,1,0]) }
            content.add(panel)

            var glowMat = UnlitMaterial()
            glowMat.color = .init(tint: s.color.withAlphaComponent(0.25))
            glowMat.faceCulling = .front
            let glow = ModelEntity(mesh: .generateSphere(radius: 1), materials: [glowMat])
            glow.position = [s.x, s.y, s.z+0.5]
            glow.scale = [s.w*0.85, s.h*1.1, 2.5]
            if s.vertical { glow.orientation = simd_quatf(angle: .pi/2, axis: [0,1,0]) }
            content.add(glow)

            var innerMat = UnlitMaterial()
            innerMat.color = .init(tint: UIColor(white:0.95,alpha:1))
            let inner = ModelEntity(mesh: .generateBox(width: s.w*0.62, height: s.h*0.28, depth: 0.22), materials: [innerMat])
            inner.position = [s.x, s.y, s.z]
            if s.vertical { inner.orientation = simd_quatf(angle: .pi/2, axis: [0,1,0]) }
            content.add(inner)

            if !s.vertical && s.y > 5 {
                var bkMat = UnlitMaterial()
                bkMat.color = .init(tint: UIColor(red:0.20,green:0.20,blue:0.24,alpha:1))
                let bkH = s.y - 2.5
                let bracket = ModelEntity(mesh: .generateBox(width: 0.12, height: bkH, depth: 0.12), materials: [bkMat])
                bracket.position = [s.x, bkH/2+2.5, s.z]; content.add(bracket)
            }
        }

        // Holographic floating displays
        let holos: [(Float,Float,Float,UIColor)] = [
            (0,6,-8, UIColor(red:0.00,green:0.80,blue:1.0,alpha:1)),
            (0,8,-20, UIColor(red:0.90,green:0.20,blue:1.0,alpha:1)),
        ]
        for h in holos {
            var holoMat = UnlitMaterial()
            holoMat.color = .init(tint: h.3.withAlphaComponent(0.30))
            let holo = ModelEntity(mesh: .generateBox(width: 3.5, height: 2.0, depth: 0.05), materials: [holoMat])
            holo.position = [h.0, h.1, h.2]; content.add(holo)
            var gridMat = UnlitMaterial()
            gridMat.color = .init(tint: h.3)
            for gy: Float in [-0.7, 0, 0.7] {
                let line = ModelEntity(mesh: .generateBox(width: 3.5, height: 0.04, depth: 0.08), materials: [gridMat])
                line.position = [h.0, h.1+gy, h.2]; content.add(line)
            }
        }
    }

    // MARK: - Street Details

    private func addStreetDetails(to content: inout RealityViewContent) {
        var metalMat = UnlitMaterial()
        metalMat.color = .init(tint: UIColor(red:0.18,green:0.18,blue:0.22,alpha:1))

        // Street lights with arms
        let lightPos: [(Float,Float)] = [
            (-5.5,-5),(5.5,-5),(-5.5,-15),(5.5,-15),(-5.5,-25),(5.5,-25),(-5.5,-35),(5.5,-35),(-5.5,-45),(5.5,-45),
        ]
        let ltColors: [UIColor] = [
            UIColor(red:0.00,green:0.75,blue:0.90,alpha:1),
            UIColor(red:0.90,green:0.05,blue:0.55,alpha:1),
        ]
        for (i, lp) in lightPos.enumerated() {
            let pole = ModelEntity(mesh: .generateCylinder(height: 5.5, radius: 0.07), materials: [metalMat])
            pole.position = [lp.0, 2.75, lp.1]; content.add(pole)
            let armX: Float = lp.0 < 0 ? lp.0+1.1 : lp.0-1.1
            let arm = ModelEntity(mesh: .generateBox(width: 2.2, height: 0.08, depth: 0.08), materials: [metalMat])
            arm.position = [armX, 5.5, lp.1]; content.add(arm)
            var glowMat = UnlitMaterial()
            glowMat.color = .init(tint: ltColors[i % ltColors.count])
            let glowX: Float = lp.0 < 0 ? lp.0+2.0 : lp.0-2.0
            let glow = ModelEntity(mesh: .generateSphere(radius: 0.28), materials: [glowMat])
            glow.position = [glowX, 5.4, lp.1]; content.add(glow)
            var poolMat = UnlitMaterial()
            let poolColor = i%2==0 ? UIColor(red:0.00,green:0.25,blue:0.38,alpha:1) : UIColor(red:0.40,green:0.02,blue:0.25,alpha:1)
            poolMat.color = .init(tint: poolColor)
            let pool = ModelEntity(mesh: .generateSphere(radius: 1), materials: [poolMat])
            pool.position = [glowX, 0.03, lp.1]; pool.scale = [3.0,0.03,3.0]; content.add(pool)
        }

        // Vendor stalls
        let stalls: [(Float,Float)] = [(-9,-6),(9,-8),(-9,-22),(9,-22),(-9,-38),(9,-38)]
        let stallNeon: [UIColor] = [
            UIColor(red:0.00,green:0.85,blue:1.0,alpha:1),
            UIColor(red:1.0,green:0.05,blue:0.55,alpha:1),
        ]
        for (i, s) in stalls.enumerated() {
            var canopyMat = UnlitMaterial()
            canopyMat.color = .init(tint: UIColor(red:0.12,green:0.10,blue:0.18,alpha:1))
            let canopy = ModelEntity(mesh: .generateBox(width: 3.0, height: 0.15, depth: 2.2), materials: [canopyMat])
            canopy.position = [s.0, 2.6, s.1]; content.add(canopy)
            let table = ModelEntity(mesh: .generateBox(width: 2.4, height: 0.10, depth: 1.6), materials: [metalMat])
            table.position = [s.0, 1.0, s.1]; content.add(table)
            for (dx,dz): (Float,Float) in [(-1.0,-0.65),(1.0,-0.65),(-1.0,0.65),(1.0,0.65)] {
                let leg = ModelEntity(mesh: .generateCylinder(height: 1.0, radius: 0.04), materials: [metalMat])
                leg.position = [s.0+dx, 0.5, s.1+dz]; content.add(leg)
            }
            var nMat = UnlitMaterial()
            nMat.color = .init(tint: stallNeon[i % stallNeon.count])
            let strip = ModelEntity(mesh: .generateBox(width: 3.0, height: 0.08, depth: 0.08), materials: [nMat])
            strip.position = [s.0, 2.48, s.1-1.0]; content.add(strip)
        }

        // Vending machines
        let vends: [(Float,Float)] = [(-9.5,-10),(9.5,-16),(-9.5,-30)]
        let vendColors: [UIColor] = [
            UIColor(red:0.00,green:0.60,blue:0.90,alpha:1),
            UIColor(red:0.90,green:0.05,blue:0.35,alpha:1),
            UIColor(red:0.10,green:0.70,blue:0.20,alpha:1),
        ]
        for (i, vp) in vends.enumerated() {
            var bodyMat = UnlitMaterial()
            bodyMat.color = .init(tint: UIColor(red:0.10,green:0.10,blue:0.14,alpha:1))
            let body = ModelEntity(mesh: .generateBox(width: 0.8, height: 1.8, depth: 0.55), materials: [bodyMat])
            body.position = [vp.0, 0.9, vp.1]; content.add(body)
            var scrMat = UnlitMaterial()
            scrMat.color = .init(tint: vendColors[i % vendColors.count])
            let screen = ModelEntity(mesh: .generateBox(width: 0.55, height: 0.8, depth: 0.06), materials: [scrMat])
            screen.position = [vp.0, 1.2, vp.1+0.29]; content.add(screen)
        }

        // Building-base neon trims
        let trims: [(Float,Float,Float,Float,UIColor)] = [
            (-9.5,0.25,-8, 14,UIColor(red:1.0,green:0.05,blue:0.55,alpha:1)),
            ( 9.5,0.25,-8, 14,UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            (-9.5,0.25,-28,12,UIColor(red:0.90,green:0.20,blue:1.0,alpha:1)),
            ( 9.5,0.25,-28,12,UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            (-9.5,0.25,-48,10,UIColor(red:1.0,green:0.55,blue:0.00,alpha:1)),
            ( 9.5,0.25,-48,10,UIColor(red:1.0,green:0.05,blue:0.55,alpha:1)),
        ]
        for (tx,ty,tz,tlen,tc) in trims {
            var tMat = UnlitMaterial()
            tMat.color = .init(tint: tc)
            let trim = ModelEntity(mesh: .generateBox(width: 0.10, height: 0.22, depth: tlen), materials: [tMat])
            trim.position = [tx, ty, tz]; content.add(trim)
        }
    }

    // MARK: - Atmosphere

    private func addAtmosphere(to content: inout RealityViewContent) {
        // Ambient glow sources at building bases
        let glows: [(Float,Float,Float,UIColor)] = [
            (-9,5,-8, UIColor(red:1.0,green:0.05,blue:0.55,alpha:1)),
            ( 9,5,-8, UIColor(red:0.00,green:0.85,blue:1.0,alpha:1)),
            (-9,5,-28,UIColor(red:0.90,green:0.55,blue:0.00,alpha:1)),
            ( 9,5,-28,UIColor(red:0.90,green:0.20,blue:1.0,alpha:1)),
        ]
        for (gx,gy,gz,gc) in glows {
            var gm = UnlitMaterial()
            gm.color = .init(tint: gc.withAlphaComponent(0.18))
            gm.faceCulling = .front
            let gs = ModelEntity(mesh: .generateSphere(radius: 5), materials: [gm])
            gs.position = [gx, gy, gz]; content.add(gs)
        }
    }

    // MARK: - Rain

    private func addRain(to content: inout RealityViewContent) {
        var rainMat = UnlitMaterial()
        rainMat.color = .init(tint: UIColor(red: 0.55, green: 0.65, blue: 0.80, alpha: 1))

        for i in 0..<150 {
            let x = (rng(i * 3) - 0.5) * 30
            let z = -(rng(i * 3 + 2) * 45)
            let fallDuration = 1.0 + Double(rng(i * 3 + 1)) * 1.5
            let delay = Double(rng(i * 3 + 3)) * fallDuration

            let drop = ModelEntity(mesh: .generateSphere(radius: 0.02), materials: [rainMat])
            drop.position = [x, -3, z]
            drop.scale = [1, 6, 1]
            content.add(drop)

            let from = Transform(scale: [1, 6, 1], translation: SIMD3<Float>(x, 25, z))
            let to   = Transform(scale: [1, 6, 1], translation: SIMD3<Float>(x, -2, z))

            let anim = FromToByAnimation<Transform>(
                from: from, to: to,
                duration: fallDuration,
                timing: .linear,
                isAdditive: false,
                bindTarget: .transform,
                delay: delay
            )
            if let resource = try? AnimationResource.generate(with: anim) {
                drop.playAnimation(resource.repeat())
            }
        }
    }

    // MARK: - Flying Vehicles

    private func addFlyingVehicles(to content: inout RealityViewContent) {
        let vehicles: [(Float,Float,Float)] = [
            (-4,30,-18),(7,45,-30),(-9,38,-48),(3,55,-25),(-5,65,-38),(11,42,-12),
            (-13,50,-28),(4,75,-52),(8,35,-42),(-2,85,-20),(6,60,-55),(-10,40,-35),
        ]
        var bodyMat = UnlitMaterial()
        bodyMat.color = .init(tint: UIColor(red:0.13,green:0.13,blue:0.18,alpha:1))
        let ltColors: [UIColor] = [
            UIColor(red:1.0,green:0.05,blue:0.55,alpha:1),
            UIColor(red:0.00,green:0.85,blue:1.0,alpha:1),
            UIColor(red:1.0,green:0.80,blue:0.00,alpha:1),
            UIColor(red:0.55,green:1.0,blue:0.10,alpha:1),
        ]
        for (i, v) in vehicles.enumerated() {
            let body = ModelEntity(mesh: .generateBox(width: 2.0, height: 0.5, depth: 4.0), materials: [bodyMat])
            body.position = [v.0, v.1, v.2]; content.add(body)

            var noseMat = UnlitMaterial()
            noseMat.color = .init(tint: UIColor(red:0.18,green:0.18,blue:0.24,alpha:1))
            let nose = ModelEntity(mesh: .generateBox(width: 1.4, height: 0.4, depth: 1.5), materials: [noseMat])
            nose.position = [v.0, v.1+0.05, v.2+2.2]; content.add(nose)

            var glassMat = UnlitMaterial()
            glassMat.color = .init(tint: UIColor(red:0.35,green:0.50,blue:0.65,alpha:1))
            let cockpit = ModelEntity(mesh: .generateSphere(radius: 0.52), materials: [glassMat])
            cockpit.position = [v.0, v.1+0.36, v.2+0.6]; cockpit.scale = [0.85,0.65,1.0]; content.add(cockpit)

            var wingMat = UnlitMaterial()
            wingMat.color = .init(tint: UIColor(red:0.16,green:0.16,blue:0.22,alpha:1))
            for dx: Float in [-1.5, 1.5] {
                let wing = ModelEntity(mesh: .generateBox(width: 1.2, height: 0.08, depth: 2.0), materials: [wingMat])
                wing.position = [v.0+dx*1.3, v.1-0.10, v.2-0.3]; content.add(wing)
            }

            var engMat = UnlitMaterial()
            engMat.color = .init(tint: ltColors[i % ltColors.count])
            for dx: Float in [-0.65, 0.65] {
                let eng = ModelEntity(mesh: .generateSphere(radius: 0.20), materials: [engMat])
                eng.position = [v.0+dx, v.1-0.12, v.2-2.0]; content.add(eng)
            }
            let trail = ModelEntity(mesh: .generateBox(width: 0.06, height: 0.06, depth: 5), materials: [engMat])
            trail.position = [v.0, v.1-0.08, v.2-4.5]; content.add(trail)

            var navMat = UnlitMaterial()
            navMat.color = .init(tint: UIColor(red:1.0,green:0.2,blue:0.2,alpha:1))
            for dx: Float in [-1.9, 1.9] {
                let nav = ModelEntity(mesh: .generateSphere(radius: 0.08), materials: [navMat])
                nav.position = [v.0+dx, v.1, v.2-0.3]; content.add(nav)
            }
        }
    }

    // MARK: - Power Lines

    private func addPowerLines(to content: inout RealityViewContent) {
        var wireMat = UnlitMaterial()
        wireMat.color = .init(tint: UIColor(red:0.14,green:0.14,blue:0.18,alpha:1))
        let lines: [(SIMD3<Float>,SIMD3<Float>)] = [
            ([-11,18,-8],  [11,20,-8]),
            ([-11,26,-20], [11,23,-20]),
            ([-11,14,-35], [11,17,-35]),
            ([-11,32,-15], [11,30,-15]),
            ([-11,22,-45], [11,20,-45]),
            ([-11,38,-28], [11,35,-28]),
        ]
        for (a,b) in lines {
            let mid = (a+b)/2
            let dir = simd_normalize(b-a)
            let wire = ModelEntity(mesh: .generateCylinder(height: simd_length(b-a), radius: 0.025), materials: [wireMat])
            wire.position = mid
            wire.orientation = simd_quatf(from: [0,1,0], to: dir)
            content.add(wire)
        }
    }
}
