//
//  File.swift
//  
//
//  Created by iMoe Nya on 2022/9/29.
//

import UIKit

open class UIKitSlider: UISlider, Slidable {
    open var direction: Direction {
        .leadingToTrailing
    }
    
    open func fit(_ viewModel: Slider.ViewModel) {
        // no scale transform
        maximumValue = Float(viewModel.maximumValue)
        minimumValue = Float(viewModel.minimumValue)
        value = Float(viewModel.value)
    }
}
