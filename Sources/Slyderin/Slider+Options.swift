//
//  File.swift
//  
//
//  Created by iMoe Nya on 2022/9/29.
//

import Foundation

public extension Slider {
    enum Option {
        @available(*, deprecated, renamed: "tracks", message: "")
        case trackingBehavior(TrackingBehavior = .trackMovement)
        case tracks(TrackingBehavior = .onTranslation)
    }
    
    struct Options {
        /// Behavior when the user moves finger on the track.
        ///
        /// The thumb won't move if the user just tapped but did not moved one's finger. To get thumb moved
        /// immediately after the touch began, change `moveToPointWhenTouchDown` to `true`.
        public var trackingBehavior: TrackingBehavior
        
        public init(
            trackingBehavior: TrackingBehavior = .onTranslation
        ) {
            self.trackingBehavior = trackingBehavior
        }
    }
    
    enum TrackingBehavior {
        @available(*, deprecated, renamed: "onLocationOnceMoved", message: "Use onMovingLocation if respondsImmediately is false, otherwise use onLocation.")
        case trackTouch(respondsImmediately: Bool)
        @available(*, deprecated, renamed: "onMovement", message: "")
        case trackMovement
        
        /// The thumb of the slider is always attached to the user's finger.
        case onLocation
        /// The thumb of the slider follows the finger once it starts moving.
        case onLocationOnceMoved
        /// The thumb of the slider moves the same distance on the same direction with the user's finger.
        case onTranslation
    }
}

extension Array where Element == Slider.Option {
    var asOptions: Slider.Options {
        var options = Slider.Options()
        for option in self {
            switch option {
            case .trackingBehavior(let behavior), .tracks(let behavior):
                options.trackingBehavior = behavior
            }
        }
        return options
    }
}
