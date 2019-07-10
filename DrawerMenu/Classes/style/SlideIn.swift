//
//  SlideIn.swift
//  DrawerMenu
//

import UIKit

public struct SlideIn: DrawerMenuStyle {
    
    public var centerViewOpacity: CGFloat = 0.05
    public var shadowColor: UIColor = .black
    public var shadowRadius: CGFloat = 2.0
    public var shadowOpacity: CGFloat = 0.5
    public var shadowOffset: CGSize = CGSize(width: 0, height: 0)
    
    public init() {}
    
    public func setup(drawer: DrawerMenu) {
        drawer.view.bringSubviewToFront(drawer.centerContainerView)
        addShadow(view: drawer.centerContainerView,
                  color: shadowColor,
                  radius: shadowRadius,
                  opacity: shadowOpacity,
                  offset: shadowOffset)
    }
    
    public func leftProgress(menuWidth: CGFloat, drawer: DrawerMenu) -> CGFloat {
        return drawer.centerContainerView.frame.minX / menuWidth
    }
    
    public func rightProgress(menuWidth: CGFloat, drawer: DrawerMenu) -> CGFloat {
        return (drawer.view.frame.width - drawer.centerContainerView.frame.maxX) / menuWidth
    }
    
    public func leftTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu) {
        drawer.leftContainerView?.frame.origin.x = -(menuWidth - (menuWidth * progress))
        drawer.centerContainerView.frame.origin.x = menuWidth * progress
        drawer.opacityView.alpha = centerViewOpacity * progress
    }
    
    public func rightTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu) {
        drawer.rightContainerView?.frame.origin.x = drawer.view.frame.width - (menuWidth * progress)
        drawer.centerContainerView.frame.origin.x = -(menuWidth * progress)
        drawer.opacityView.alpha = centerViewOpacity * progress
    }
}
