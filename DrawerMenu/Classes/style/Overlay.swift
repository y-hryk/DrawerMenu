//
//  Overlay.swift
//  DrawerMenu
//

import UIKit

public struct Overlay: DrawerMenuStyle {
    
    public var centerViewOpacity: CGFloat = 0.3
    public var shadowColor: UIColor = .black
    public var shadowOpacity: CGFloat = 0.7
    public var shadowRadius: CGFloat = 2.0
    public var shadowOffset: CGSize = CGSize(width: 0, height: 0)
    
    public init() {}
    
    public func setup(drawer: DrawerMenu) {
        drawer.view.sendSubviewToBack(drawer.centerContainerView)
        addShadow(view: drawer.leftContainerView,
                  color: shadowColor,
                  radius: shadowRadius,
                  opacity: shadowOpacity,
                  offset: shadowOffset)
        addShadow(view: drawer.rightContainerView,
                  color: shadowColor,
                  radius: shadowRadius,
                  opacity: shadowOpacity,
                  offset: shadowOffset)
    }
    
    public func leftProgress(menuWidth: CGFloat, drawer: DrawerMenu) -> CGFloat {
        guard let left = drawer.leftContainerView else { return 0 }
        return left.frame.maxX / menuWidth
    }
    
    public func rightProgress(menuWidth: CGFloat, drawer: DrawerMenu) -> CGFloat {
        guard let right = drawer.rightContainerView else { return 0 }
        return (drawer.view.frame.width - right.frame.origin.x) / menuWidth
    }
    
    public func leftTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu) {
        guard let left = drawer.leftContainerView else { return }
        left.frame.origin.x = menuWidth * progress - left.frame.width
        drawer.opacityView.alpha = centerViewOpacity * progress
    }
    public func rightTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu) {
        guard let right = drawer.rightContainerView else { return }
        right.frame.origin.x = drawer.view.frame.maxX - (menuWidth * progress)
        drawer.opacityView.alpha = centerViewOpacity * progress
    }
}
