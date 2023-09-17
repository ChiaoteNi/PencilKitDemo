//
//  CustomToolPickerDemo.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/12.
//

import SwiftUI
import PencilKit
import Combine

struct CustomToolPickerDemo: View {

    @StateObject 
    var viewModel: CustomToolPickerViewModel

    @State var canvasView = PKCanvasView()
    @State var strokeWidth: CGFloat = 0

    @State
    private var subscriptions = Set<AnyCancellable>()

    init() {
        _viewModel = StateObject(wrappedValue: CustomToolPickerViewModel())
        canvasView.drawingPolicy = .anyInput
    }

    var body: some View {
        HStack {
            VStack {
                HStack {
                    Button(action: {
                        canvasView.undoManager?.undo()
                    }, label: {
                        Text("Undo")
                    })
                    Button(action: {
                        canvasView.undoManager?.redo()
                    }, label: {
                        Text("Redo")
                    })
                }
                PencilKitCanvas(canvasView: canvasView)
                    .task {
                        viewModel.$currentTool
                            .sink { newTool in
                                canvasView.tool = newTool
                            }.store(in: &subscriptions)
                    }
                Slider(value: $strokeWidth, in: 1...50) { _ in
                    viewModel.updateLineWidth(strokeWidth)
                }
            }
            VStack {
                ForEach(PKInkingTool.InkType.allCases, id: \.rawValue) { type in
                    // A quick way to create a title for demonstration purposes. Please avoid using this in production code
                    toolButton(title: type.title) {
                        viewModel.updateInkType(with: type)
                    }
                }
                Spacer()
                    .frame(height: 50)
                ForEach(PKEraserTool.EraserType.allCases, id: \.hashValue) { type in
                    toolButton(title: type.title) {
                        viewModel.updateEraser(with: type)
                    }
                }
            }
        }
    }
}

extension CustomToolPickerDemo {

    @ViewBuilder
    private func toolButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            Text(title)
                .font(.caption)
                .frame(maxWidth: 50)
        })
        .padding(5)
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 5), style: /*@START_MENU_TOKEN@*/FillStyle()/*@END_MENU_TOKEN@*/)
        .shadow(radius: 3)
    }
}

extension PKInkingTool.InkType: CaseIterable {
    public static var allCases: [PKInkingTool.InkType] {
        [.pen, .pencil, .marker, .crayon, .fountainPen, .monoline, .watercolor]
    }

    // The following code is just a quick way to create a title for this demonstration.
    // Please avoid using this in production code
    fileprivate var title: String {
        rawValue.replacingOccurrences(of: "com.apple.ink.", with: "")
    }
}

extension PKEraserTool.EraserType: CaseIterable {
    public static var allCases: [PKEraserTool.EraserType] {
        [.bitmap, .fixedWidthBitmap, .vector]
    }

    fileprivate var title: String {
        switch self {
        case .bitmap:
            return "bitmap"
        case .fixedWidthBitmap:
            return "fixedWidthBitmap"
        case .vector:
            return "vector"
        @unknown default:
            return "unknown"
        }
    }
}

#Preview {
    CustomToolPickerDemo()
}
