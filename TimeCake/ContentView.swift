//
//  ContentView.swift
//  TimeCake
//
//  Created by Steven Pease on 3/30/24.
//

import SceneKit
import SwiftUI
import RealityKit

func buildCylinder(color: UIColor, secondsElapsed: UInt64, secondsTotal: UInt64) -> Entity {
    let heightPerSecond: Double = 0.000002
    let height = heightPerSecond * Double(secondsTotal)
    let height_2 = Float(height/2.0)
    let transparentHeight = Float((Double(secondsElapsed) / Double(secondsTotal)) * height)
    let cylinderHeight = Float(height) - transparentHeight
    let radius = Float(0.05)
    
    let anchorEntity = Entity()
    
    let transparent = ModelEntity(mesh: .generateCylinder(height: transparentHeight, radius: radius), materials: [SimpleMaterial(color: color.withAlphaComponent(0.5), roughness: 0.5, isMetallic: false)])
    transparent.transform.translation = simd_float3(x: 0.0, y: height_2 - transparentHeight/2.0, z: -0.2)
    let cylinderEntity = ModelEntity(mesh: .generateCylinder(height: cylinderHeight, radius: radius), materials: [SimpleMaterial(color: color, roughness: 0.0, isMetallic: false)])
    cylinderEntity.transform.translation = simd_float3(x: 0.0, y: cylinderHeight / 2.0 - height_2, z: -0.2)
    cylinderEntity.components.set(
        CollisionComponent(
            shapes: [.generateBox(size: [radius*2,Float(cylinderHeight), radius*2])],
              mode: .default,
              filter: .default
        )
    )
    cylinderEntity.components.set(HoverEffectComponent())
    cylinderEntity.components.set(InputTargetComponent())
    
    anchorEntity.addChild(transparent)
    anchorEntity.addChild(cylinderEntity)
    anchorEntity.components.set(
        CollisionComponent(
            shapes: [.generateBox(size: [radius*2, Float(height), radius*2])],
            mode: .default,
            filter: .default
        )
    )
    anchorEntity.components.set(HoverEffectComponent())
    anchorEntity.components.set(InputTargetComponent())
    
    return anchorEntity
}

class ModeData {
    var secondsTotal: UInt64
    @State var secondsElapsed: UInt64 = 0
    var timeRemaining: String {
        get {
            let secondsLeft = self.secondsTotal - self.secondsElapsed
            if secondsLeft > 3600 {
                return String(format: "%.1f", Float(secondsLeft) / 3600.0)
            }
            return String(secondsLeft / 60)
        }
    }
    
    init(secondsTotal: UInt64) {
        self.secondsTotal = secondsTotal
    }
}

private var selectedEntity: ModeData! = nil

struct ContentView: View {
    @State private var work: ModeData = ModeData(secondsTotal: 36000)
    @State private var play: ModeData = ModeData(secondsTotal: 21600)
    @State private var sleep: ModeData = ModeData(secondsTotal: 28800)
    
    var body: some View {
        HStack {
            buildCake()
            VStack {
                buildButton(mode: self.work, color: .red)
                buildButton(mode: self.play, color: .green)
                buildButton(mode: self.sleep, color: .blue)
            }
        }
        .padding()
    }
    
    func buildButton(mode: ModeData, color: some ShapeStyle) -> some View {
        Button(mode.timeRemaining, action: {
            print("BUTTON \(mode)!!")
            selectedEntity = mode
        })
        .font(.largeTitle)
        .tint(color)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func buildCake() -> some View {
        VStack {
            RealityView { content in
                content.add(buildCylinder(color: .red, secondsElapsed: work.secondsElapsed, secondsTotal: work.secondsTotal))
            }
            .padding(0)
            .gesture(SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded({ _ in
                    print("WORK!!!")
                    selectedEntity = work
                    selectedEntity.secondsElapsed += 1000
            }))
            RealityView { content in
                content.add(buildCylinder(color: .green, secondsElapsed: play.secondsElapsed, secondsTotal: play.secondsTotal))
            }
            .padding(0)
            .gesture(TapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    selectedEntity = play
            }))
            RealityView { content in
                content.add(buildCylinder(color: .blue, secondsElapsed: sleep.secondsElapsed, secondsTotal: sleep.secondsTotal))
            }
            .gesture(TapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    selectedEntity = sleep
            }))
            .padding(0)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
