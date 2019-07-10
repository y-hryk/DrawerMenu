//
//  Floating.swift
//  DrawerMenu
//

import UIKit

public struct Floating: DrawerMenuStyle {
    
    public var centerViewOpacity: CGFloat = 0.05
    public var centerScale: CGFloat = 0.6
    public var shadowColor: UIColor = .black
    public var shadowRadius: CGFloat = 6.0
    public var shadowOpacity: CGFloat = 0.4
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
        guard let left = drawer.leftContainerView else { return 0 }
        return left.frame.maxX / menuWidth
    }
    
    public func rightProgress(menuWidth: CGFloat, drawer: DrawerMenu) -> CGFloat {
        guard let right = drawer.rightContainerView else { return 0 }
        return (drawer.view.frame.width - right.frame.origin.x) / menuWidth
    }
    
    public func leftTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu) {
        drawer.rightContainerView?.frame.origin.x = drawer.view.frame.width
        drawer.leftContainerView?.frame.origin.x = -(menuWidth - (menuWidth * progress))
        drawer.opacityView.alpha = centerViewOpacity * progress
        
        let scale = 1 - ((1 - centerScale) * progress)
        let centerTranslate = CGAffineTransform(translationX: (drawer.centerContainerView.bounds.width * 0.55) * progress, y: 0.0)
        let centerScale = CGAffineTransform(scaleX: scale, y: scale)
        drawer.centerContainerView.layer.transform = CATransform3DMakeAffineTransform(centerScale.concatenating(centerTranslate))
    }
    public func rightTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu) {
        drawer.leftContainerView?.frame.origin.x = -menuWidth
        drawer.rightContainerView?.frame.origin.x = drawer.view.frame.width - (menuWidth * progress)
        drawer.opacityView.alpha = centerViewOpacity * progress
        
        let scale = 1 - ((1 - centerScale) * progress)
        let centerTranslate = CGAffineTransform(translationX: -((drawer.centerContainerView.bounds.width * 0.55) * progress), y: 0.0)
        let centerScale = CGAffineTransform(scaleX: scale, y: scale)
        drawer.centerContainerView.layer.transform = CATransform3DMakeAffineTransform(centerScale.concatenating(centerTranslate))
    }
}
