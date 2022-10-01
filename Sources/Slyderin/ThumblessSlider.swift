//
//  File.swift
//  
//
//  Created by iMoe Nya on 2022/10/1.
//

import UIKit

open class ThumblessSlider: UIView, Slidable {
    public enum CornerRadius {
        case full
        case fixed(CGFloat)
    }
    
    public struct ScaleRatio {
        public var ratioOnAxis: CGFloat
        public var ratioAgainstAxis: CGFloat
        public init(ratioOnAxis: CGFloat, ratioAgainstAxis: CGFloat) {
            self.ratioOnAxis = ratioOnAxis
            self.ratioAgainstAxis = ratioAgainstAxis
        }
    }
    
    public let direction: Direction
    public let scaleRatio: ScaleRatio
    public let cornerRadius: CornerRadius
    open var visualEffect: UIVisualEffect? {
        didSet {
            visualEffectView.effect = visualEffect
        }
    }
    
    open class var defaultScaleRatio: ScaleRatio {
        ScaleRatio(ratioOnAxis: 1.05, ratioAgainstAxis: 2)
    }
    
    open class var defaultDirection: Direction {
        .leadingToTrailing
    }
    
    open class var defaultCornerRadius: CornerRadius {
        .full
    }
    
    open class var defaultVisualEffect: UIVisualEffect {
        UIBlurEffect(style: .systemUltraThinMaterial)
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        fillingView?.backgroundColor = tintColor
    }
    
    struct VisualEffectViewConstraints {
        var width: NSLayoutConstraint!
        var height: NSLayoutConstraint!
        
        var scaledWidth: NSLayoutConstraint!
        var scaledHeight: NSLayoutConstraint!
        
        var scaled: Bool {
            get {
                width.isActive == false && scaledWidth.isActive
            }
            set {
                let scaled = newValue
                // deactivate before activating to avoid ambiguity complains
                if scaled {
                    width.isActive = false
                    height.isActive = false
                    scaledWidth.isActive = true
                    scaledHeight.isActive = true
                } else {
                    scaledWidth.isActive = false
                    scaledHeight.isActive = false
                    width.isActive = true
                    height.isActive = true
                }
            }
        }
    }
    
    var visualEffectViewConstraints = VisualEffectViewConstraints()
    
    public init(
        direction: Direction = defaultDirection,
        scaleRatio: ScaleRatio = defaultScaleRatio,
        cornerRadius: CornerRadius = defaultCornerRadius,
        visualEffect: UIVisualEffect = defaultVisualEffect
    ) {
        self.direction = direction
        self.scaleRatio = scaleRatio
        self.cornerRadius = cornerRadius
        self.visualEffect = visualEffect
        super.init(frame: .zero)
        buildView()
    }
    
    public required init?(coder: NSCoder) {
        self.direction = Self.defaultDirection
        self.scaleRatio = Self.defaultScaleRatio
        self.cornerRadius = Self.defaultCornerRadius
        self.visualEffect = Self.defaultVisualEffect
        super.init(coder: coder)
        buildView()
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateCornerRadius(getCornerRadius())
    }
    
    private weak var fillingView: UIView!
    private weak var variableConstraint: NSLayoutConstraint!
    private weak var visualEffectView: UIVisualEffectView!
    
    public var fillingLength: CGFloat = 0 {
        didSet {
            fitFillingLength(fillingLength)
        }
    }
    
    private func getCornerRadius() -> CGFloat {
        switch cornerRadius {
        case .fixed(let fixedValue):
            return fixedValue
        case .full:
            return projection(
                of: visualEffectView.frame.size,
                on: direction.axis.counterpart
            ) / 2
        }
    }
    
    private func updateCornerRadius(_ cornerRadius: CGFloat) {
        if self.layer.cornerRadius != cornerRadius {
            self.layer.cornerRadius = cornerRadius
            visualEffectView.layer.cornerRadius = cornerRadius
        }
    }
    
    public func fit(_ viewModel: Slyder.ViewModel) {
        let valueRatio = viewModel.value / (viewModel.maximumValue + viewModel.minimumValue)
        let fillingLength = getFillingViewLength(byRatio: valueRatio, when: viewModel.interacting)
        if self.fillingLength != fillingLength {
            self.fillingLength = fillingLength
        }
        
        let shouldScale = viewModel.interacting
        if visualEffectViewConstraints.scaled != shouldScale {
            visualEffectViewConstraints.scaled = shouldScale
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: {
                    if shouldScale {
                        return 0.8
                    } else {
                        return 0.55
                    }
                }(),
                initialSpringVelocity: {
                    if shouldScale {
                        return 20
                    } else {
                        return 0
                    }
                }()
            ) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
}


// MARK: filling
private extension ThumblessSlider {
    func getFillingViewLength(
        byRatio ratio: CGFloat,
        when interacting: Bool
    ) -> CGFloat {
        let size = bounds.size
        if interacting{
            return ratio * scaleRatio.ratioOnAxis * projection(of: size, on: direction.axis)
        } else {
            return ratio * projection(of: size, on: direction.axis)
        }
    }
    
    func fitFillingLength(_ length: CGFloat) {
        variableConstraint.constant = length
    }
}



// MARK: build
private extension ThumblessSlider {
    func buildView() {
        layer.masksToBounds = false
        
        let visualEffectView = UIVisualEffectView(effect: visualEffect)
        self.visualEffectView = visualEffectView
        visualEffectView.layer.cornerCurve = .continuous
        visualEffectView.clipsToBounds = true
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        visualEffectView.centerYAnchor.constraint(equalTo: centerYAnchor)
            .isActive = true
        visualEffectView.centerXAnchor.constraint(equalTo: centerXAnchor)
            .isActive = true
        
        visualEffectViewConstraints.width = visualEffectView.widthAnchor.constraint(equalTo: widthAnchor)
        visualEffectViewConstraints.height = visualEffectView.heightAnchor.constraint(equalTo: heightAnchor)
        visualEffectViewConstraints.scaledWidth = visualEffectView.widthAnchor.constraint(
            equalTo: widthAnchor,
            multiplier: {
                switch direction.axis {
                case .xAxis:
                    return scaleRatio.ratioOnAxis
                case .yAxis:
                    return scaleRatio.ratioAgainstAxis
                }
            }()
        )
        visualEffectViewConstraints.scaledHeight = visualEffectView.heightAnchor.constraint(
            equalTo: heightAnchor,
            multiplier: {
                switch direction.axis {
                case .xAxis:
                    return scaleRatio.ratioAgainstAxis
                case .yAxis:
                    return scaleRatio.ratioOnAxis
                }
            }()
        )
        visualEffectViewConstraints.scaled = false
        
        let fillingView = UIView()
        self.fillingView = fillingView
        fillingView.backgroundColor = tintColor
        visualEffectView.contentView.addSubview(fillingView)
        fillingView.translatesAutoresizingMaskIntoConstraints = false
        
        switch direction.axis {
        case .xAxis:
            fillingView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor)
                .isActive = true
            fillingView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor)
                .isActive = true
            variableConstraint = fillingView.widthAnchor.constraint(equalToConstant: 0)
            variableConstraint.isActive = true

        case .yAxis:
            fillingView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor)
                .isActive = true
            fillingView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor)
                .isActive = true
            variableConstraint = fillingView.heightAnchor.constraint(equalToConstant: 0)
            variableConstraint.isActive = true
        }
        
        switch direction {
        case .leadingToTrailing:
            fillingView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor)
                .isActive = true
        case .trailingToLeading:
            fillingView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor)
                .isActive = true
        case .leftToRight:
            fillingView.leftAnchor.constraint(equalTo: visualEffectView.contentView.leftAnchor)
                .isActive = true
        case .rightToLeft:
            fillingView.rightAnchor.constraint(equalTo: visualEffectView.contentView.rightAnchor)
                .isActive = true
        case .topToBottom:
            fillingView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor)
                .isActive = true
        case .bottomToTop:
            fillingView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor)
                .isActive = true
        }
    }
}

