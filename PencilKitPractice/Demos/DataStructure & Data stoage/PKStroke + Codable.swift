//
//  PKStroke + Codable.swift
//  PencilKitPractice
//
//  Created by Chiaote Ni on 2023/9/17.
//

import Foundation
import PencilKit
import CoreGraphics

/*
 It's just a quick demonstration about how to implement the converting process between the PKStroke and Data.
 Highly recommend to create your own data model if you need to save the raw data instead of just a Image result
 */


// A light way implementation for the demonstration.
struct StrokeCodingError: Error {
    let message: String
}

extension PKStroke: Codable {

    private enum CodingKeys: String, CodingKey {
        case ink
        case path
        case transform
        case mask
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ink, forKey: CodingKeys.ink)
        try container.encode(path, forKey: CodingKeys.path)
        try container.encode(transform, forKey: CodingKeys.transform)

        guard let mask else { return }
        let maskData = try mask.cgPath.encode()
        try container.encode(maskData, forKey: CodingKeys.mask)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let ink = try container.decode(PKInk.self, forKey: CodingKeys.ink)
        let path = try container.decode(PKStrokePath.self, forKey: CodingKeys.path)
        let transform = try container.decode(CGAffineTransform.self, forKey: CodingKeys.transform)

        let mask: UIBezierPath? = try {
            guard let maskData = try container.decodeIfPresent(Data.self, forKey: CodingKeys.mask) else {
                return nil
            }
            let cgPath = try maskData.decodeToCGPath()
            return UIBezierPath(cgPath: cgPath)
        }()

        self.init(
            ink: ink,
            path: path,
            transform: transform,
            mask: mask
        )
        
    }
}

extension PKStrokePath: Codable {

    private enum CodingKeys: String, CodingKey {
        case points
        case createDate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let points = try container.decode([PKStrokePoint].self, forKey: CodingKeys.points)
        let creationDate = try container.decode(Date.self, forKey: CodingKeys.createDate)

        self.init(
            controlPoints: points,
            creationDate: creationDate
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(map { $0 }, forKey: CodingKeys.points)
        try container.encode(creationDate, forKey: CodingKeys.createDate)
    }
}

extension PKStrokePoint: Codable {

    private enum CodingKeys: String, CodingKey {
        case location
        case timeOffset
        case size // point size
        case opacity
        case force
        case azimuth
        case altitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let location = try container.decode(CGPoint.self, forKey: CodingKeys.location)
        let timeOffset = try container.decode(TimeInterval.self, forKey: CodingKeys.timeOffset)
        let size = try container.decode(CGSize.self, forKey: CodingKeys.size)
        let opacity = try container.decode(CGFloat.self, forKey: CodingKeys.opacity)
        let force = try container.decode(CGFloat.self, forKey: CodingKeys.force)
        let azimuth = try container.decode(CGFloat.self, forKey: CodingKeys.azimuth)
        let altitude = try container.decode(CGFloat.self, forKey: CodingKeys.altitude)

        self.init(
            location: location,
            timeOffset: timeOffset,
            size: size,
            opacity: opacity,
            force: force,
            azimuth: azimuth,
            altitude: altitude
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: CodingKeys.location)
        try container.encode(timeOffset, forKey: CodingKeys.timeOffset)
        try container.encode(size, forKey: CodingKeys.size)
        try container.encode(opacity, forKey: CodingKeys.opacity)
        try container.encode(force, forKey: CodingKeys.force)
        try container.encode(azimuth, forKey: CodingKeys.azimuth)
        try container.encode(altitude, forKey: CodingKeys.altitude)
    }
}

extension PKInk: Codable {

    private enum CodingKeys: String, CodingKey {
        case inkType    // PKInk.InkType
        case color      // UIColor
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inkType, forKey: CodingKeys.inkType)

        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (.zero, .zero, .zero, .zero)
        let isSuccess = color.getRed(&r, green: &g, blue: &b, alpha: &a)

        if isSuccess {
            try container.encode([r, g, b, a], forKey: .color)
        } else {
            throw StrokeCodingError(message: "rgba get failed")
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let inkType = {
            do {
                return try container.decode(PKInk.InkType.self, forKey: CodingKeys.inkType)
            } catch {
                assertionFailure("unsupported inkType") // There're some new inkTypes released in iOS 17
                return .pen
            }
        }()

        let components = try container.decode([CGFloat].self, forKey: .color)
        guard components.count == 4 else {
            throw StrokeCodingError(message: "color decode failed")
        }
        let color = UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])

        self.init(inkType, color: color)
    }
}

extension PKInk.InkType: Codable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = PKInk.InkType(rawValue: rawValue) ?? .pen // before iOS 17: 0 ~ 3, after iOS 17: 0 ~ 7
    }
}

private struct PathElement: Codable {
    var type: CGPathElementType
    var points: [CGPoint]?
}

extension CGPathElementType: Codable {

}

extension CGPath {

    func encode() throws -> Data {
        var elements = [PathElement]()
        applyWithBlock { pointer in
            let element = pointer.pointee

            var points = [CGPoint]()
            for i in 0 ..< numPoints(forType: element.type) {
                points.append(element.points[i])
            }
            elements.append(PathElement(type: element.type, points: points))
        }
        let encoder = JSONEncoder()
        return try encoder.encode(elements)
    }

    private func numPoints(forType type: CGPathElementType) -> Int {
        switch type {
        case .moveToPoint:          return 1
        case .addLineToPoint:       return 1
        case .addQuadCurveToPoint:  return 2
        case .addCurveToPoint:      return 3
        case .closeSubpath:         return 0
        default:                    return 0
        }
    }
}

extension Data {

    func decodeToCGPath() throws -> CGPath {
        let decoder = JSONDecoder()
        let elements = try decoder.decode([PathElement].self, from: self)

        return elements.reduce(into: CGMutablePath()) { path, element in
            if element.type == .closeSubpath {
                path.closeSubpath()
                return
            }

            guard let points = element.points else {
                return
            }
            switch element.type {
            case .moveToPoint:
                path.move(to: points[0])
            case .addLineToPoint:
                path.addLine(to: points[0])
            case .addCurveToPoint:
                path.addQuadCurve(to: points[1], control: points[0])
            case .addQuadCurveToPoint:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            default:
                break
            }
        }
    }
}
