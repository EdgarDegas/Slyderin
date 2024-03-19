import UIKit

open class Slyder: UIView {
    open internal(set) var slider: Slidable
    open internal(set) var options: Options
    
    /// Invoked when the value of `Slyder` object changes.
    ///
    /// Might get invoked with repeating values for multiple times.
    open var valueChangeHandler: ((Double) -> Void)?
    
    open func onValueChange(_ closure: ((Double) -> Void)?) -> Self {
        self.valueChangeHandler = closure
        return self
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        slider.tintColor = tintColor
    }
    
    open class func DefaultSlider() -> Slidable {
        ThumblessSlider()
    }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        get {
            super.semanticContentAttribute
        }
        set {
            super.semanticContentAttribute = newValue
            slider.semanticContentAttribute = newValue
        }
    }
    
    public init(slider: Slidable = DefaultSlider(), options: [Option] = []) {
        self.options = options.asOptions
        self.slider = slider
        super.init(frame: .zero)
        buildView()
        fit(viewModel)
    }
    
    private var valueWhenTouchBegan: Double?
    private var touchPointWhenBagan: CGPoint?
    
    public override init(frame: CGRect) {
        self.slider = Self.DefaultSlider()
        self.options = Options()
        super.init(frame: frame)
        buildView()
        fit(viewModel)
    }
    
    public required init?(coder: NSCoder) {
        self.slider = Self.DefaultSlider()
        self.options = Options()
        super.init(coder: coder)
        buildView()
        fit(viewModel)
    }
    
    open var viewModel = ViewModel() {
        didSet {
            fit(viewModel)
            let value = viewModel.value
            if value != oldValue.value {
                valueChangeHandler?(value)
            }
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        viewModel.interacting = true
        valueWhenTouchBegan = viewModel.value
        touchPointWhenBagan = location
        handleTouchDown(on: location)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        guard
            let valueWhenTouchBegan,
            let touchPointWhenBagan
        else {
            return
        }
        let location = touch.location(in: self)
        switch options.trackingBehavior {
        case .trackMovement:
            let translation = CGVector(
                dx: location.x - touchPointWhenBagan.x,
                dy: location.y - touchPointWhenBagan.y
            )
            viewModel = updateViewModel(
                viewModel, by: translation, from: valueWhenTouchBegan
            )
        case .trackTouch:
            viewModel = updateViewModel(viewModel, to: location)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        viewModel.interacting = false
        valueWhenTouchBegan = nil
        touchPointWhenBagan = nil
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        viewModel.interacting = false
        valueWhenTouchBegan = nil
        touchPointWhenBagan = nil
    }
}


// MARK: tracking
private extension Slyder {
    func handleTouchDown(on point: CGPoint) {
        switch options.trackingBehavior {
        case .trackMovement:
            break
        case .trackTouch(let respondsImmediately):
            guard respondsImmediately else {
                return
            }
            viewModel = updateViewModel(viewModel, to: point)
        }
    }
    
    func updateViewModel(
        _ viewModel: ViewModel,
        by translation: CGVector,
        from valueWhenTouchBegan: Double
    ) -> ViewModel {
        let ratio = slider.scalar(of: translation, on: slider.direction) /
            slider.projection(of: slider.bounds.size, on: slider.direction.axis)
        let valueChange = ratio * (viewModel.maximumValue - viewModel.minimumValue)
        let value = valueWhenTouchBegan + valueChange
        var viewModel = viewModel
        viewModel.value = clampValue(value, ofViewModel: viewModel)
        return viewModel
    }
    
    func updateViewModel(_ viewModel: ViewModel, to point: CGPoint) -> ViewModel {
        let point = convert(point, to: slider)
        let pointValue = slider.value(of: point, on: slider.direction.axis)
        var ratio = pointValue / slider.projection(of: slider.bounds.size, on: slider.direction.axis)
        if !slider.sliderValuePositivelyCorrelativeToCoordinateSystem {
            ratio = 1 - ratio
        }
        let value = (viewModel.maximumValue + viewModel.minimumValue) * ratio
        var viewModel = viewModel
        viewModel.value = clampValue(value, ofViewModel: viewModel)
        return viewModel
    }
    
    func clampValue(_ value: Double, ofViewModel viewModel: ViewModel) -> Double {
        if value > viewModel.maximumValue {
            return viewModel.maximumValue
        }
        if value < viewModel.minimumValue {
            return viewModel.minimumValue
        }
        return value
    }
}


// MARK: build view
private extension Slyder {
    func fit(_ viewModel: ViewModel) {
        slider.fit(viewModel)
    }
    
    func buildView() {
        directionalLayoutMargins = .init(
            top: 20, leading: 20, bottom: 20, trailing: 20
        )
        
        isMultipleTouchEnabled = false  // don't support multiple touch
        self.addSubview(slider)
        
        slider.tintColor = tintColor
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
            .isActive = true
        slider.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
            .isActive = true
        slider.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
            .isActive = true
        slider.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            .isActive = true
        
        slider.isUserInteractionEnabled = false
    }
}
