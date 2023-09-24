//
//  StrokeStore.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/18.
//

import Foundation
import PencilKit

final class DrawingStore: DrawingStoring {

    private let strokeStorageKey = "strokeSaving.strokes"

    func save(strokes: [PKStroke]) {
        do {
            let data = try JSONEncoder().encode(strokes)
            UserDefaults.standard.set(data, forKey: strokeStorageKey)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func retrieveDrawing() -> [PKStroke]? {
        guard let data = UserDefaults.standard.data(forKey: strokeStorageKey) else {
            return nil
        }
        do {
            let strokes = try JSONDecoder().decode([PKStroke].self, from: data)
            return strokes
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
}
