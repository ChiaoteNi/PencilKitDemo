//
//  ContentView.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: PART I
                NavigationLink("Basic") {
                    BasicDemo()
                }
                Spacer()
                NavigationLink("Custom Tool Picker") {
                    CustomToolPickerDemo()
                }
                Spacer()
                NavigationLink("CGPath to Stroke") {
                    PathToStrokesDemo()
                }
                Spacer()
                NavigationLink("Stroke Data Model") {
                    StrokeSavingDemo()
                }
            }
            .padding(50)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
