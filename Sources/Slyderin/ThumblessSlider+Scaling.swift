//
//  File.swift
//  
//
//  Created by iMoe Nya on 2024/3/19.
//

import Foundation

public extension ThumblessSlider {
    public enum Scaling {
        case onAxis(_ ratio: CGFloat)
        case againstAxis(_ ratio: CGFloat)
        case none
        case both(onAxis: CGFloat, againstAxis: CGFloat)
        
        var scaleRatio: ScaleRatio {
            switch self {
            case .none:
                return ScaleRatio(onAxis: 1, againstAxis: 1)
            case .againstAxis(let ratio):
                return ScaleRatio(onAxis: 1, againstAxis: ratio)
            case .onAxis(let ratio):
                return ScaleRatio(onAxis: ratio, againstAxis: 1)
            case .both(let onAxis, let againstAxis):
                return ScaleRatio(onAxis: onAxis, againstAxis: againstAxis)
            }
        }
    }
}
