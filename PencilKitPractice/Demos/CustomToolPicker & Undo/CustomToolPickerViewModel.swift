//
//  CustomToolPickerViewModel.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/12.
//

import Foundation
import PencilKit
import Combine

final class CustomToolPickerViewModel: NSObject, ObservableObject {

    private enum Tool {
        case ink(inkType: PKInkingTool.InkType)
        case eraser(eraserType: PKEraserTool.EraserType)
    }

    @Published
    var currentTool: PKTool = PKInkingTool(.pen, color: .clear, width: 0)
    @Published
    var strokeWidth: CGFloat = 1

    @Published
    private var selectedToolType: Tool = .ink(inkType: .pen)
    @Published
    private var inkColor: UIColor = .black

    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        $selectedToolType
            .combineLatest($strokeWidth, $inkColor)
            .sink { [weak self] toolType, lineWidth, color in
                guard let self else { return }
                switch toolType {
                case .ink(let type):
                    self.currentTool = PKInkingTool(type, color: color, width: lineWidth)
                case .eraser(let type):
                    self.currentTool = PKEraserTool(type, width: lineWidth * 3)
                }
            }.store(in: &subscriptions)
    }

    func updateInkType(with newInkType: PKInkingTool.InkType) {
        selectedToolType = .ink(inkType: newInkType)
    }

    func updateEraser(with newEraserType: PKEraserTool.EraserType) {
        selectedToolType = .eraser(eraserType: newEraserType)
    }

    func updateLineWidth(_ newLineWidth: CGFloat) {
        strokeWidth = newLineWidth
    }

    func updateColor(_ newColor: UIColor) {
        inkColor = newColor
    }
}
