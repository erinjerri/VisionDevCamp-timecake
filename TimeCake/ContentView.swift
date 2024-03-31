//
//  ContentView.swift
//  TimeCake
//
//  Created by Steven Pease on 3/30/24.
//

import SceneKit
import SwiftUI
import RealityKit

var selectedEntity: Mode = .work

enum Mode {
    case work, play, sleep
}

func buildCylinder(color: UIColor, secondsElapsed: UInt64, secondsTotal: UInt64) -> Entity {
    let heightPerSecond: Double = 0.000002
    let height = heightPerSecond * Double(secondsTotal)
    let transparentHeight = Float((Double(secondsElapsed) / Double(secondsTotal)) * height)
    let cylinderHeight = Float(height) - transparentHeight
    let radius = Float(0.05)
    
    let anchorEntity = Entity()
    
    let transparent = ModelEntity(mesh: .generateCylinder(height: transparentHeight, radius: radius), materials: [SimpleMaterial(color: color.withAlphaComponent(0.5), roughness: 0.5, isMetallic: false)])
    transparent.transform.translation = simd_float3(x: 0.0, y: cylinderHeight / 2.0, z: -0.2)
    let cylinderEntity = ModelEntity(mesh: .generateCylinder(height: cylinderHeight, radius: radius), materials: [SimpleMaterial(color: color, roughness: 0.0, isMetallic: false)])
    cylinderEntity.transform.translation = simd_float3(x: 0.0, y: -cylinderHeight / 2.0, z: -0.2)
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

struct ModeData {
    var secondsTotal: UInt64
    @State var secondsElapsed: UInt64 = 0
    
    func secondsRemaining() -> UInt64 {
        self.secondsTotal - self.secondsElapsed
    }
}

struct ContentView: View {
    @State private var work: ModeData = ModeData(secondsTotal: 36000)
    @State private var play: ModeData = ModeData(secondsTotal: 21600)
    @State private var sleep: ModeData = ModeData(secondsTotal: 28800)
    
    var body: some View {
        HStack {
            buildCake()
            VStack {
                HStack {
                    Text(String(work.secondsRemaining()))
                        .padding()
                        .background(.red)
                        .font(.largeTitle)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack {
                    Text(String(play.secondsRemaining()))
                        .padding()
                        .background(.green)
                        .font(.largeTitle)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack {
                    /*
                    RealityView { content in
                        content.add(buildCylinder(color: .blue, secondsElapsed: 18000, secondsTotal: 36000))
                    }
                    .padding(0)
                     */
                    Text(String(sleep.secondsRemaining()))
                        .padding()
                        .background(.blue)
                        .font(.largeTitle)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
    
    func buildCake() -> some View {
        VStack {
            RealityView { content in
                content.add(buildCylinder(color: .red, secondsElapsed: work.secondsElapsed, secondsTotal: work.secondsTotal))
            }
            .padding(0)
            .gesture(TapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    print("WORK!!!")
                    selectedEntity = .work
                    work.secondsElapsed += 1
            }))
            RealityView { content in
                content.add(buildCylinder(color: .green, secondsElapsed: play.secondsElapsed, secondsTotal: play.secondsTotal))
            }
            .padding(0)
            .gesture(TapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    selectedEntity = .play
            }))
            RealityView { content in
                content.add(buildCylinder(color: .blue, secondsElapsed: sleep.secondsElapsed, secondsTotal: sleep.secondsTotal))
            }
            .gesture(TapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    selectedEntity = .sleep
            }))
            .padding(0)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
