//
//  StrokeSavingInteractor.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/17.
//

import Foundation
import PencilKit

protocol DrawingStoring {
    func save(strokes: [PKStroke])
    func retrieveDrawing() -> [PKStroke]?
}

final class StrokeSavingInteractor {

    var displaying: (any StrokeSavingDemoStateStoring)? {
        didSet {
            displaying?.hasStoredStrokes = strokeStorage.retrieveDrawing() != nil
        }
    }
    let strokeStorage: DrawingStoring

    init(strokeStorage: DrawingStoring) {
        self.strokeStorage = strokeStorage
    }

    func clearDrawing() {
        displaying?.currentStrokes = []
    }

    func save(drawing: PKDrawing) {
        strokeStorage.save(strokes: drawing.strokes)
        displaying?.hasStoredStrokes = true
    }

    func retrieveDrawing() {
        guard let strokes = strokeStorage.retrieveDrawing() else {
            return
        }
        displaying?.currentStrokes = strokes
    }
}
