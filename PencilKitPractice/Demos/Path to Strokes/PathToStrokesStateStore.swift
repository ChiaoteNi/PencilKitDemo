//
//  PathToStrokesStateStore.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/18.
//

import Foundation
import PencilKit

protocol PathToStrokesDemoStateStoring: ObservableObject {
    var currentStrokes: [PKStroke] { get set }
}

final class PathToStrokesDemoStateStore: PathToStrokesDemoStateStoring {
    @Published
    var currentStrokes: [PKStroke] = []
}
