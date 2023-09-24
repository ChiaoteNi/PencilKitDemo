//
//  MultipleLayersViewModel.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/25.
//

import Foundation
import PencilKit
import SwiftUI

struct CanvasLayerInfo: Identifiable, Equatable {
    let id: Int
    let canvas: PKCanvasView

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

final class MultipleLayersViewModel: ObservableObject {
    @Published var canvases: [CanvasLayerInfo] = []

    func addCanvas(with toolPicker: PKToolPicker, isBackgroundEnabled: Bool = false) {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.becomeFirstResponder()

        if isBackgroundEnabled {
            let image = UIImage(named: "Stock")
            canvas.layer.contents = image?.cgImage
        }

        toolPicker.addObserver(canvas)
        toolPicker.setVisible(true, forFirstResponder: canvas)

        let id = canvases.count
        let info = CanvasLayerInfo(id: id, canvas: canvas)
        canvases.append(info)
    }

    func removeLastCanvas() {
        canvases.removeLast()
    }
}
