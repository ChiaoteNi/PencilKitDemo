//
//  BasicDemo.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/10.
//

import SwiftUI
import PencilKit

struct BasicDemo: View {

    @StateObject var viewModel: BasicDemoViewModel

    @State var canvasView = PKCanvasView()
    @State var toolPicker = PKToolPicker()

    @State var isShareSheetPresented: Bool = false

    init(viewModel: BasicDemoViewModel = BasicDemoViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)

        canvasView.tool = PKInkingTool(.pen, color: .black, width: 30)
        /// **drawingPolicy:**
        /// Default is: if a `PKToolPicker` is visible, respect `UIPencilInteraction.prefersPencilOnlyDrawing`,
        /// otherwise only pencil touches draw.
        canvasView.drawingPolicy = .anyInput//.pencilOnly
        canvasView.delegate = viewModel
        canvasView.becomeFirstResponder()
//        canvasView.overrideUserInterfaceStyle = .dark

//        toolPicker.showsDrawingPolicyControls = true
        // Set up observer to notify the canvasView when the selectedToll changed
        toolPicker.addObserver(canvasView)
        // Only display the toolPicker when the canvasView has become the FirstResponder.
        toolPicker.setVisible(true, forFirstResponder: canvasView)
//        toolPicker.overrideUserInterfaceStyle = .dark

    }

    var body: some View {
        VStack {
            HStack {
                Text(verbatim: viewModel.title)
                Button("Clear") {
                    canvasView.drawing = PKDrawing()
                }
                Button(action: {
                    isShareSheetPresented = true
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                .sheet(isPresented: $isShareSheetPresented, onDismiss: {
                    isShareSheetPresented = false
                }, content: {
                    let image = canvasView.drawing.image(
                        from: canvasView.bounds,
                        scale: canvasView.contentScaleFactor
                    )
                    // In this demo we only show the image with a sheet
                    // However, you can use the UIActivityViewController to share the result or save it to the album directly
                    Image(uiImage: image)
                })

            }
            ZStack {
                PencilKitCanvas(canvasView: canvasView)
                ForEach(viewModel.visibleRectsInfo) { displayedRect in
                    let rect = displayedRect.rect
                    Rectangle()
                        .border(Color.blue, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.clear)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                }
            }
        }
    }

}

final class BasicDemoViewModel: NSObject, ObservableObject {

    struct VisibleRectInfo: Identifiable {
        let id: Int
        let rect: CGRect
        let rgb: (Float, Float, Float)
    }

    @Published var title: String = ""
    @Published var visibleRectsInfo: [VisibleRectInfo] = []

    private func updateTitle(with text: String) {
        title = text
    }

    private func updateTitle(with drawing: PKDrawing) {
        let count = drawing.strokes.count
        title = "\(count)"

        visibleRectsInfo = drawing.strokes.enumerated().map { index, stroke in
            // NOTE: PKStroke has already conformed the RandomAccessCollection
            // , which means you can access the point directly instead of via the interpolatedPoint
            VisibleRectInfo(
                id: index,
                rect: stroke.renderBounds, // The renderBounds will reflect the bounds that it looks like.
//                rect: stroke.path.boundingRect(), // However, you'll find out that the entire path didn't change.
//                rect: stroke.mask?.bounds ?? .zero, // It's because the Pencil kit framework implement the result with creating a mask for the path, and copy a new stroke with each mask.
                rgb: (0.1, 0.1, 0.1)
            )
        }

    }
}

extension BasicDemoViewModel: PKCanvasViewDelegate {
    /// Called after the drawing on the canvas did change.
    ///
    /// This may be called some time after the `canvasViewDidEndUsingTool:` delegate method.
    /// For example, when using the Apple Pencil, pressure data is delayed from touch data, this
    /// means that the user can stop drawing (`canvasViewDidEndUsingTool:` is called), but the
    /// canvas view is still waiting for final pressure values; only when the final pressure values
    /// are received is the drawing updated and this delegate method called.
    ///
    /// It is also possible that this method is not called, if the drawing interaction is cancelled.
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateTitle(with: canvasView.drawing)
    }
    /// Called after setting `drawing` when the entire drawing is rendered and visible.
    ///
    /// This method lets you know when the canvas view finishes rendering all of the currently
    /// visible content. This can be used to delay showing the canvas view until all content is visible.
    ///
    /// This is called every time the canvasView transitions from partially rendered to fully rendered,
    /// including after setting the drawing, and after zooming or scrolling.
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {

    }
    /// Called when the user starts using a tool, eg. selecting, drawing, or erasing.
    ///
    /// This does not include moving the ruler.
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        updateTitle(with: "DidBegin")
    }
    /// Called when the user stops using a tool, eg. selecting, drawing, or erasing.
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        updateTitle(with: "DidEnd")
    }
}

#Preview {
    BasicDemo()
}
