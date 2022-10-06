# Slyderin

An iOS-16-styled slider.

Available on iOS 13 and later.

https://user-images.githubusercontent.com/12840982/194141815-8c48bb74-e792-4d92-b43f-919c4834b2d8.mov

## How to Use

Include it with Swift Package Manager.

Add it to your view:

```Swift
import Slyderin
class ViewController: UIViewController {   
    private weak var slider: Slyder!
	// ......
    func loadView() {
        super.loadView()
        let slider = Slyder()
        view.addSubview(slider)
        // your layout code......
    }
	// ......
}
```

The size of the `Slyder` is **not intrinsic**. And it includes a default **20px margin** on each side of the slider to increase the touch area, which cause the slider to be insetted. You can change it by changing its `directionalLayoutMargins`.

Use `valueChangeHandler` or call `onValueChange(_:)` to receive value changes:

```Swift
Slyder()
    .height(50)
    .onValueChange {
		// new value $0 received
    }
```

`Slyder` supports 2 different modes of tracking, you can specify it when initializing: 

```Swift
Slyder(options: [.trackingBehavior()])
```

- The default tracking behavior is `.trackMovement`, which means the slider value changes according to the finger movements distance on the slider's direction.
- The other mode is `.trackTouch(respondsImmediately: Bool)`. In this mode, the thumb (the filled track) moves to where the finger is. If `respondsImmediately` is `true`, the value changes immediately when the user put the finger down onto the slider. Otherwise the value won't change until the user moves the finger.



## Make Your Own Slyder

You can specify a slider when initializing `Slyder`, as long as it is `Slidable`:

```Swift
init(slider: Slidable = DefaultSlider(), options: [Option] = [])
```



### UIKit values

`Slyder` respects some of the standard UIKit parameters:

- `tintColor` changes the color of the filled track. Inherited from the superview by default.
- `directionalLayoutMargins` determines the slider's margins from its touch-responsive area. Defaults to 20px each side.
- `semanticContentAttribute` determines whether the slider should flip when the interface layout direction is right-to-left. Defaults to `unspecifed`, which means it flips. Changes to this value won't apply until the next time the `Slyder` is added to superview.
- `overrideUserInterfaceStyle` determines the blur effect is light or dark, if you have not specify a light or dark one.



### Parameters of the default slider

Slyderin uses `Slyderin.ThumblessSlider` by default. You can change its initializer's parameters to more-or-less do some customizations:

```Swift
Slyder(
    slider: ThumblessSlider(
        direction: .bottomToTop,
        scaleRatio: ThumblessSlider.ScaleRatio(ratioOnAxis: 1.05, ratioAgainstAxis: 1.15),
        cornerRadius: .fixed(12),
        visualEffect: UIBlurEffect(style: .systemMaterialDark)
    )
)
```

- `direction` determines how whether the slider is horizontal or vertical and which way the track is filled, e.g.,: 
    - `leadingToTrailing`. The slider is horizontal and the track is filled from the leading side to the trailing side when the user slides in leading-to-trailing direction. This is the default direction.
    - `bottomToTop`. The slider is vertical and the track is filled from bottom to top when the user slides upwards.
- `scaleRatio`. The slider expands its size when responding to user inputs. This parameter specifies the expanding ratio. 
    - Defaults to 1.05 on the axis of the direction, and 2.0 against the axis. Which, for a horizontal slider, its width expands 1.05 times and its height becomes 2.0 times.
- `cornerRadius` provides 2 different modes of corner radius:
    - `full`, the corner radius equals half the length against the `direction`'s axis. For a horizontal slider with a height of 20px, the corner radius is 10px.
    - `fixed(CGFloat)`, a fixed corner radius.
- `visualEffect` specifies the visual effect of the unfilled track.



There is an animation parameter on the way.



### A built-in `UISlider`

There is also a built-in `UISlider` subclass: `Slyderin.UIKitSlider`, which, unfortunately, supports only the leading-to-trailing direction:

```Swift
Slyder(slider: UIKitSlider())
```

https://user-images.githubusercontent.com/12840982/194141894-fc9b7596-9be8-4247-bc0c-d422760a7591.mov

### Your own implementation

You can implement your own `Slidable`:

```Swift
public protocol Slidable: AnyObject where Self: UIView {
    var direction: Direction { get }
    func fit(_ viewModel: Slyder.ViewModel)
}

extension Slyder {
    public struct ViewModel {
        public var maximumValue: Double = 1
        public var minimumValue: Double = 0
        public var value: Double = 0
        public var interacting: Bool = false
    }
}
```

`Slidable` is a simple protocol. Your implementation should provides the direction it supports (or support multiple directions) and update itself according  to the value changes.

