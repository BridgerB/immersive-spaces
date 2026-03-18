//
//  SceneContent.swift
//  immersive-spaces
//

import SwiftUI
import RealityKit

protocol SceneContent {
    func build(content: inout RealityViewContent) async
}
