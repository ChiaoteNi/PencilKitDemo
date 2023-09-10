//
//  PencilKitCanvas.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/10.
//

import SwiftUI
import PencilKit

struct PencilKitCanvas: UIViewRepresentable {

    let canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
