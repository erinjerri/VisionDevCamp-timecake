//
//  ContentView.swift
//  TimeCake
//
//  Created by Steven Pease on 3/30/24.
//

import SceneKit
import SwiftUI
import RealityKit
import RealityKitContent

func buildCylinder(color: UIColor) -> Entity {
    let materialVar = SimpleMaterial(color: color, roughness: 0, isMetallic: false)
        let cylinderEntity = ModelEntity(mesh: .generateCylinder(height: 0.02, radius: 0.1), materials: [materialVar])
    return cylinderEntity
}

struct ContentView: View {
    var body: some View {
        HStack {
            /*
            SceneKitContainer()
                        .edgesIgnoringSafeArea(.all)
            */
            VStack {
                HStack {
                    RealityView { content in
                        content.add(buildCylinder(color: .red))
                    }
                    Text("8 hrs")
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.75))
                        .font(.largeTitle)
                    Text("25%")
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.75))
                        .font(.largeTitle)
                }
                HStack {
                    RealityView { content in
                        content.add(buildCylinder(color: .green))
                    }
                    Text("8 hrs")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                    Text("25%")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                }
                HStack {
                    RealityView { content in
                        content.add(buildCylinder(color: .blue))
                    }
                    Text("8 hrs")
                        .foregroundColor(.teal)
                        .font(.largeTitle)
                    Text("25%")
                        .foregroundColor(.teal)
                        .font(.largeTitle)
                }
            }
        }
        .padding()
    }
}

struct SceneKitContainer: UIViewRepresentable {
    // Create a SceneKit view
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        // Create a SceneKit scene
        let scene = SCNScene()
        
        do {
            let cylinder = SCNCylinder(radius: 5, height: 0.5)
            cylinder.firstMaterial!.diffuse.contents = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.5)
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinderNode.position = SCNVector3(0, 0, 10)
            scene.rootNode.addChildNode(cylinderNode)
        }
        do {
            let cylinder = SCNCylinder(radius: 5, height: 0.5)
            cylinder.firstMaterial!.diffuse.contents = UIColor.black
            cylinder.firstMaterial?.fillMode = .lines
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinderNode.position = SCNVector3(0, 0, 10)
            scene.rootNode.addChildNode(cylinderNode)
        }
        do {
            let cylinder = SCNCylinder(radius: 5, height: 0.5)
            cylinder.firstMaterial!.diffuse.contents = UIColor.red
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinderNode.position = SCNVector3(0, -0.5, 10)
            scene.rootNode.addChildNode(cylinderNode)
        }
        
        do {
            let cylinder = SCNCylinder(radius: 5, height: 1.0)
            cylinder.firstMaterial!.diffuse.contents = UIColor.green
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinderNode.position = SCNVector3(0, -1.5, 10)
            scene.rootNode.addChildNode(cylinderNode)
        }
        
        do {
            let cylinder = SCNCylinder(radius: 5, height: 1.0)
            cylinder.firstMaterial!.diffuse.contents = UIColor.blue
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinderNode.position = SCNVector3(0, -2.75, 10)
            scene.rootNode.addChildNode(cylinderNode)
        }
        
        // Set the scene to the scene view
        sceneView.scene = scene
        
        // Allow the user to manipulate the camera
        sceneView.allowsCameraControl = true
        
        return sceneView
    }
    
    // Update the SceneKit view
    func updateUIView(_ uiView: SCNView, context: Context) {}
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
