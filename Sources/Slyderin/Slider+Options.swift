//
//  File.swift
//  
//
//  Created by iMoe Nya on 2022/9/29.
//

import Foundation

public extension Slider {
    enum Option {
        case trackingBehavior(TrackingBehavior = .trackMovement)
    }
    
    struct Options {
        /// Behavior when the user moves finger on the track.
        ///
        /// The thumb won't move if the user just tapped but did not moved one's finger. To get thumb moved
        /// immediately after the touch began, change `moveToPointWhenTouchDown` to `true`.
        public var trackingBehavior: TrackingBehavior
        
        public init(
            trackingBehavior: TrackingBehavior = .trackMovement
        ) {
            self.trackingBehavior = trackingBehavior
        }
    }
    
    enum TrackingBehavior {
        /// The thumb of the slider is attached to the user's finger.
        case trackTouch(respondsImmediately: Bool)
        /// The thumb of the slider moves the same distance on the same direction with the user's finger.
        case trackMovement
    }
}

extension Array where Element == Slider.Option {
    var asOptions: Slider.Options {
        var options = Slider.Options()
        for option in self {
            switch option {
            case .trackingBehavior(let behavior):
                options.trackingBehavior = behavior
            }
        }
        return options
    }
}
