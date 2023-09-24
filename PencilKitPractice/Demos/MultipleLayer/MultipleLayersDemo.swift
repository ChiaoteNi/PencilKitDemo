//
//  MultipleLayerDemo.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/19.
//

import SwiftUI
import PencilKit
import PencilKit

/*
 In this demo, you add one canvas and draw some lines on it first.
 Then, add another one, draw on it as well, then use eraser to erase the lines.
 You'll see you'll only be able to erase the lines that are in the last layer.
 */
struct MultipleLayersDemo: View {

    @StateObject var viewModel = MultipleLayersViewModel()
    @State var toolPicker = PKToolPicker()

    var body: some View {
        VStack {
            HStack {
                toolButton(title: "Add one") {
                    viewModel.addCanvas(with: toolPicker)
                }
                toolButton(title: "Add one with Background") {
                    viewModel.addCanvas(with: toolPicker, isBackgroundEnabled: true)
                }
                toolButton(title: "Remove one") {
                    viewModel.removeLastCanvas()
                }
            }
            ZStack(content: {
                ForEach(viewModel.canvases) { canvasLayerInfo in
                    PencilKitCanvas(canvasView: canvasLayerInfo.canvas)
                        .frame(width: 300, height: 600)

                }
            })
        }
    }
}

extension MultipleLayersDemo {

    @ViewBuilder
    private func toolButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            Text(title)
        })
        .padding(10)
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 20), style: /*@START_MENU_TOKEN@*/FillStyle()/*@END_MENU_TOKEN@*/)
        .shadow(radius: 3)
    }
}

#Preview {
    MultipleLayersDemo()
}
