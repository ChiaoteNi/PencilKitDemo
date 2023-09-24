//
//  StrokeSavingDemoStore.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/17.
//

import Foundation
import PencilKit

protocol StrokeSavingDemoStateStoring: ObservableObject {
    var currentStrokes: [PKStroke] { get set }
    var hasStoredStrokes: Bool { get set }
}

final class StrokeSavingDemoStateStore: StrokeSavingDemoStateStoring {

    @Published
    var currentStrokes: [PKStroke] = []

    @Published
    var hasStoredStrokes: Bool = false
}
