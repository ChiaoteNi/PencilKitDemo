//
//  StrokeDataSavingDemo.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/17.
//

import SwiftUI
import PencilKit
import Combine

struct StrokeSavingDemo: View {

    @State var interactor: StrokeSavingInteractor
    @StateObject var stateStore: StrokeSavingDemoStateStore

    @State var canvasView = PKCanvasView()
    @State var toolPicker = PKToolPicker()

    @State
    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: StrokeSavingInteractor = StrokeSavingInteractor(strokeStorage: DrawingStore()),
        stateStore: StrokeSavingDemoStateStore = StrokeSavingDemoStateStore()
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
            HStack {
                Button(action: {
                    interactor.save(drawing: canvasView.drawing)
                }, label: {
                    Text("Save strokes")
                })
                Button(action: {
                    interactor.clearDrawing()
                }, label: {
                    Text("Clear")
                })

                if stateStore.hasStoredStrokes {
                    Button(action: {
                        interactor.retrieveDrawing()
                    }, label: {
                        Text("Retrieve strokes")
                    })
                }
            }
            PencilKitCanvas(canvasView: canvasView)
//                .onChange(of: stateStore.currentDrawing, { oldValue, newValue in
//                    guard let newValue, oldValue != newValue else { return }
//                    canvasView.drawing = newValue
//                })
                .task {
                    stateStore.$currentStrokes
                        .sink { strokes in
                            canvasView.drawing.strokes = strokes
                        }.store(in: &subscriptions)
                }
        }
    }
}

#Preview {
    StrokeSavingDemo()
}
