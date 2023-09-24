//
//  PathToStrokesDemo.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/18.
//

import SwiftUI
import PencilKit
import Combine

struct PathToStrokesDemo: View {

    @State var interactor: PathToStrokesDemoInteractor
    @StateObject var stateStore: PathToStrokesDemoStateStore

    @State var canvasView = PKCanvasView()
    @State var toolPicker = PKToolPicker()

    @State
    private var inputText: String = ""
    @State
    private var subscription = Set<AnyCancellable>()

    init(
        interactor: PathToStrokesDemoInteractor = PathToStrokesDemoInteractor(pathGenerator: CGPathGenerator()),
        stateStore: PathToStrokesDemoStateStore = PathToStrokesDemoStateStore()
    ) {
        interactor.displaying = stateStore

        _interactor = State(wrappedValue: interactor)
        _stateStore = StateObject(wrappedValue: stateStore)

        canvasView.drawingPolicy = .anyInput
        canvasView.becomeFirstResponder()

        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
    }

    var body: some View {
        VStack {
            TextField(text: $inputText, prompt: Text(verbatim: "Type something here")) {
                Text(verbatim: "Type something here")
            }.padding(30)

            HStack {
                Button(action: {
                    guard let ink = toolPicker.selectedTool as? PKInkingTool else { return }
                    interactor.updateStrokes(
                        with: inputText,
                        inkTool: ink,
                        font: .boldSystemFont(ofSize: 256)
                    )
                }, label: {
                    Text("Convert")
                })
                Button(action: {
                    interactor.clear()
                }, label: {
                    Text("Clear")
                })
            }
            PencilKitCanvas(canvasView: canvasView)
                .task {
                    stateStore.$currentStrokes
                        .sink { strokes in
                            canvasView.drawing.strokes = strokes
                            canvasView.becomeFirstResponder()
                        }.store(in: &subscription)
                }
        }
    }
}

#Preview {
    PathToStrokesDemo()
}
