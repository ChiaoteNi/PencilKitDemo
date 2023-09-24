//
//  PathToStrokesInteractor.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/18.
//

import CoreGraphics
import PencilKit

protocol PathGenerating {
    func makePath(with text: String, font: UIFont) -> CGPath
}

final class PathToStrokesDemoInteractor {

    var displaying: (any PathToStrokesDemoStateStoring)?

    let pathGenerator: PathGenerating

    init(pathGenerator: PathGenerating) {
        self.pathGenerator = pathGenerator
    }

    func updateStrokes(with text: String, inkTool: PKInkingTool, font: UIFont) {
        let generatedPath = pathGenerator.makePath(with: text, font: font)
        let stroke = makeStroke(
            with: generatedPath,
            ink: inkTool.ink,
            pointSize: CGSize(width: inkTool.width, height: inkTool.width)
        )
        displaying?.currentStrokes = [stroke]
    }

    func clear() {
        displaying?.currentStrokes = []
    }
}

extension PathToStrokesDemoInteractor {

    private func makeStroke(with path: CGPath, ink: PKInk, pointSize: CGSize) -> PKStroke {
        var points = [PKStrokePoint]()
        path.applyWithBlock { pointer in
            let element = pointer.pointee
            let point = PKStrokePoint(
                location: element.points.pointee,
                timeOffset: 1,
                size: pointSize,
                opacity: 0.5,
                force: 0.5,
                azimuth: .zero,
                altitude: .zero
            )
            points.append(point)
        }
        let stroke = PKStroke(ink: ink, path: PKStrokePath(
            controlPoints: points,
            creationDate: Date()
        ))
        return stroke
    }
}
