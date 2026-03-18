//
//  SceneContent.swift
//  immersive-spaces
//

import RealityKit

protocol SceneContent {
    func build(content: inout RealityViewContent) async
}
