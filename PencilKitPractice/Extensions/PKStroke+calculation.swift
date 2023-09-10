//
//  PKStroke+calculation.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/10.
//

import Foundation
import PencilKit

extension PKStrokePath {
    
    func boundingRect() -> CGRect {
        guard let first = self.first?.location else {
            return .zero
        }
        return reduce(CGRect(origin: first, size: .zero)) { partialResult, strokePoint in
            let point = strokePoint.location
            let width = strokePoint.size.width / 2
            let height = strokePoint.size.height / 2

            let minX = Swift.min(partialResult.minX, point.x - width)
            let minY = Swift.min(partialResult.minY, point.y - height)
            let maxX = Swift.max(partialResult.maxX, point.x + width)
            let maxY = Swift.max(partialResult.maxY, point.y + height)

            return CGRect(
                x: minX,
                y: minY,
                width: maxX - minX,
                height: maxY - minY
            )
        }
    }
}
