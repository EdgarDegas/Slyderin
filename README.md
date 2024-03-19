# Slyderin

An iOS-16-styled slider.

Available on iOS 13 and later. Supports RTL.

https://user-images.githubusercontent.com/12840982/194141815-8c48bb74-e792-4d92-b43f-919c4834b2d8.mov

## How to Use

Use Swift Package Manager to add it to your project. On how to use Swift Package Manager, read this: https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app

`import Slyderin` into your source file, and add a `Slider` object to your view:

```Swift
import Slyderin
class ViewController: UIViewController {   
    private weak var slider: Slider!
	// ......
    func loadView() {
        super.loadView()
        let slider = Slider()
        view.addSubview(slider)
        // your layout code......
    }
	// ......
}
```

### About Layout

**The size of the `Slider` is not intrinsic**, meaning it won't have a size of its own. You have to prevent its size or position from being ambiguous. For example, if you set a bottom constraint for it, you then have to set a top constraint or a height constraint for it, too. 



**A `Slider` has a built-in padding of 20px on each side by default, to increase the touch area.** This causes the slider to be indented. For example, if you want a slider to fit in some view with a 20px padding on each side:

```swift
slider.fillSuperview(padding: 20)
```

Then you will find the paddings have become 40px, due to the extra built-in 20px paddings. The built-in 20px padding is there for the touch area. The recommendation is to keep it and reduce your outer padding to 0px:

```swift
slider.fillSuperview(padding: 0)
```

However, if you do want to change the paddings, they are in its `directionalLayoutMargins`.



### About Value Changes

Set the slider's `valueChangeHandler` or call `onValueChange(_:)` to receive value changes:

```Swift
Slider()
    .height(50)
    .onValueChange {
		// new value $0 received
    }
```





### Parameters of the default slider

Slyderin uses `Slyderin.ThumblessSlider` by default. You can change its initializer's parameters to more-or-less do some customizations:

```Swift
Slider(
    slider: ThumblessSlider(
        direction: .bottomToTop,
        scaling: .both(onAxis: 1.05, againstAxis: 1.15),
        cornerRadius: .fixed(12),
        visualEffect: UIBlurEffect(style: .systemMaterialDark)
    )
)
```

- `direction` determines whether the slider is horizontal or vertical and how the track is filled, e.g.,: 

    - `leadingToTrailing`. The slider is horizontal and the track is filled from the leading side to the trailing side when the user slides in leading-to-trailing direction. This is the default direction.
    - `bottomToTop`. The slider is vertical and the track is filled from bottom to top when the user slides upwards.

- `scaling`. The slider expands its size when responding to user inputs. This parameter specifies the expanding ratio. If you set it to `.both(onAxis: 1.05, againstAxis: 1.15)`, for a horizontal slider, its becomes 1.05 times wider and 1.15 times taller. Defaults to (1, 1).

- `cornerRadius` provides 2 different modes of corner radius:

    - `full`, the corner radius equals half the length against the `direction`'s axis. For a horizontal slider with a height of 20px, the corner radius is 10px.
    - `fixed(CGFloat)`, a fixed corner radius.

- `visualEffect` specifies the visual effect of the unfilled track.

> There is a new animation parameter on the way.



### About Tracking Modes

`Slider` supports 2 different modes of tracking. Specify it when initializing: 

```Swift
Slider(options: [.tracks( /* .onTranslation, .onLocation or .onLocationOnceMoved */ )])
```

- The default tracking behavior is `.onTranslation`. In this mode, the slider cares about the finger's movements and distances, instead of its position. It's the same as Safari video player progress bar in iOS 16.
- The other modes (`.onLocation` / `.onLocationOnceMoved`), the thumb (the filled track) moves to where the finger is. Specifically, under `.onLocationOnceMoved` mode, the slider won't start tracking until the finger moves.


---

## Make Your Own Slider

You can specify a slider when initializing `Slider`, as long as it is `Slidable`:

```Swift
init(slider: Slidable = DefaultSlider(), options: [Option] = [])
```



### UIKit values

`Slider` respects some of the standard UIKit parameters:

- `tintColor` changes the color of the filled track. Inherited from the superview by default.
- `directionalLayoutMargins` determines the slider's margins from its touch-responsive area. Defaults to 20px each side.
- `semanticContentAttribute` determines whether the slider should flip when the interface layout direction is right-to-left. Defaults to `unspecifed`, which means it flips. Changes to this value won't apply until the next time the `Slider` is added to superview.
- `overrideUserInterfaceStyle` determines the blur effect is light or dark, if you have not specify a light or dark one.



### A built-in `UISlider`

There is also a built-in `UISlider` subclass: `Slyderin.UIKitSlider`, which, unfortunately, supports only the leading-to-trailing direction:

```Swift
Slider(slider: UIKitSlider())
```

https://user-images.githubusercontent.com/12840982/194141894-fc9b7596-9be8-4247-bc0c-d422760a7591.mov

### Your own implementation

You can implement your own `Slidable`:

```Swift
public protocol Slidable: AnyObject where Self: UIView {
    var direction: Direction { get }
    func fit(_ viewModel: Slider.ViewModel)
}

extension Slider {
    public struct ViewModel {
        public var maximumValue: Double = 1
        public var minimumValue: Double = 0
        public var value: Double = 0
        public var interacting: Bool = false
    }
}
```

`Slidable` is a simple protocol. Your implementation should provides the direction it supports (or support multiple directions) and update itself according  to the value changes.

