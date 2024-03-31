//
//  ContentView.swift
//  TimeCake
//
//  Created by Steven Pease on 3/30/24.
//

import SceneKit
import SwiftUI
import RealityKit

func updateCylinder(secondsElapsed: UInt32, secondsTotal: UInt32, anchorEntity: some Entity) {
    let radius = Float(0.05)
    let heightPerSecond: Double = 0.000002
    let height = heightPerSecond * Double(secondsTotal)
    let height_2 = Float(height/2.0)
    
    let transparentHeight = Float((Double(secondsElapsed) / Double(secondsTotal)) * height)
    let cylinderHeight = Float(height) - transparentHeight
    
    anchorEntity.components.set(
        CollisionComponent(
            shapes: [.generateBox(size: [radius*2, Float(height), radius*2])],
            mode: .default,
            filter: .default
        )
    )
    
    let outline = anchorEntity.children[0]
    outline.transform.translation = simd_float3(x: 0.0, y: height_2 - transparentHeight/2.0, z: -0.2)
    outline.transform.scale = simd_float3(x: 1.0, y: transparentHeight, z: 1.0)
    
    let fill = anchorEntity.children[1]
    fill.components.set(
        CollisionComponent(
            shapes: [.generateBox(size: [radius*2,Float(cylinderHeight), radius*2])],
              mode: .default,
              filter: .default
        )
    )
    fill.transform.translation = simd_float3(x: 0.0, y: cylinderHeight / 2.0 - height_2, z: -0.2)
    fill.transform.scale = simd_float3(x: 1.0, y: cylinderHeight, z: 1.0)
}

func buildCylinder(color: UIColor, secondsElapsed: UInt32, secondsTotal: UInt32) -> Entity {
    let radius = Float(0.05)
    
    let anchorEntity = Entity()
    
    let transparent = ModelEntity(mesh: .generateCylinder(height: 1.0, radius: radius), materials: [SimpleMaterial(color: color.withAlphaComponent(0.5), roughness: 0.5, isMetallic: false)])
    
    let cylinderEntity = ModelEntity(mesh: .generateCylinder(height: 1.0, radius: radius), materials: [SimpleMaterial(color: color, roughness: 0.0, isMetallic: false)])
    
    cylinderEntity.components.set(HoverEffectComponent())
    cylinderEntity.components.set(InputTargetComponent())
    
    anchorEntity.addChild(transparent)
    anchorEntity.addChild(cylinderEntity)
    anchorEntity.components.set(HoverEffectComponent())
    anchorEntity.components.set(InputTargetComponent())
    
    updateCylinder(secondsElapsed: secondsElapsed, secondsTotal: secondsTotal, anchorEntity: anchorEntity)
    
    return anchorEntity
}

func computeTimeRemaining(secondsElapsed: UInt32, secondsTotal: UInt32) -> String {
    let secondsLeft: Int64 = Int64(secondsTotal) - Int64(secondsElapsed)
    if abs(secondsLeft) > 3600 {
        return String(format: "%.1f Hours", Float(secondsLeft) / 3600.0)
    } else {
        return String(format: "%.0f Minutes", Float(secondsLeft) / 60.0)
    }
}

class ModeData: ObservableObject {
    var secondsTotal: UInt32
    @Published var secondsElapsed: UInt32 = 0 {
        didSet {
            self.timeRemaining = computeTimeRemaining(secondsElapsed: secondsElapsed, secondsTotal: self.secondsTotal)
        }
    }
    @Published var timeRemaining: String
    
    init(secondsTotal: UInt32) {
        self.secondsTotal = secondsTotal
        self.timeRemaining = computeTimeRemaining(secondsElapsed: 0, secondsTotal: secondsTotal)
    }
}

private var selectedEntity: ModeData! = nil

struct ContentView: View {
    @StateObject private var work: ModeData = ModeData(secondsTotal: 36000)
    @StateObject private var play: ModeData = ModeData(secondsTotal: 21600)
    @StateObject private var sleep: ModeData = ModeData(secondsTotal: 28800)
    private var timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
        selectedEntity?.secondsElapsed += 40
    })
    
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
            } update: { content in
                updateCylinder(secondsElapsed: work.secondsElapsed, secondsTotal: work.secondsTotal, anchorEntity: content.entities[0])
            }
            .padding(0)
            .gesture(SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded({ _ in
                    print("WORK!!!")
                    selectedEntity = work
            }))
            RealityView { content in
                content.add(buildCylinder(color: .green, secondsElapsed: play.secondsElapsed, secondsTotal: play.secondsTotal))
            } update: { content in
                updateCylinder(secondsElapsed: play.secondsElapsed, secondsTotal: play.secondsTotal, anchorEntity: content.entities[0])
            }
            .padding(0)
            .gesture(TapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    selectedEntity = play
            }))
            RealityView { content in
                content.add(buildCylinder(color: .blue, secondsElapsed: sleep.secondsElapsed, secondsTotal: sleep.secondsTotal))
            } update: { content in
                updateCylinder(secondsElapsed: sleep.secondsElapsed, secondsTotal: sleep.secondsTotal, anchorEntity: content.entities[0])
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
