//
//  CGPathGenerator.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/19.
//

import UIKit

final class CGPathGenerator: PathGenerating {

    func makePath(with text: String, font: UIFont) -> CGPath {
        let paths = CGMutablePath()
        let fontRef = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let attributedString = NSAttributedString(string: text, attributes: [kCTFontAttributeName as NSAttributedString.Key: fontRef])

        let line = CTLineCreateWithAttributedString(attributedString)
        let runs: [CTRun] = CTLineGetGlyphRuns(line) as! [CTRun]

        for run in runs {
            let attribute: NSDictionary = CTRunGetAttributes(run)
            let ctFont = attribute[kCTFontAttributeName] as! CTFont

            for i in 0 ..< CTRunGetGlyphCount(run) {
                // take one glyph from run
                let range = CFRange(location: i, length: 1)
                // create array to hold glyphs, this should have array with one item
                var glyphs = [CGGlyph](repeating: 0, count: range.length)
                // create position holder
                var position = CGPoint()
                // get glyph
                CTRunGetGlyphs(run, range, &glyphs)
                // glyph position
                CTRunGetPositions(run, range, &position)
                // append glyph path to letters
                for glyph in glyphs {
                    guard let path = CTFontCreatePathForGlyph(ctFont, glyph, nil) else { continue }
                    paths.addPath(path, transform: CGAffineTransform(translationX: position.x, y: position.y))
                }
            }
        }

        let rotatedPath = CGMutablePath()
        rotatedPath.addPath(paths, transform: CGAffineTransform(scaleX: 1, y: -1))

        let movedPath = CGMutablePath()
        movedPath.addPath(rotatedPath, transform: CGAffineTransform(
            translationX: 0,
            y: rotatedPath.boundingBoxOfPath.height
        ))
        return movedPath
    }
}
