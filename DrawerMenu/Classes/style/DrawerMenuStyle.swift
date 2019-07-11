//
//  DrawerMenuStyle.swift
//  DrawerMenu
//

import UIKit

public protocol DrawerMenuStyle {
    func setup(drawer: DrawerMenu)
    func leftProgress(menuWidth: CGFloat, drawer: DrawerMenu) -> CGFloat
    func rightProgress(menuWidth: CGFloat, drawer: DrawerMenu) -> CGFloat
    func leftTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu)
    func rightTransition(menuWidth: CGFloat, progress: CGFloat, drawer: DrawerMenu)
}

public extension DrawerMenuStyle {
    func addShadow(view: UIView?, color: UIColor, radius: CGFloat, opacity: CGFloat, offset: CGSize) {
        view?.layer.shadowColor = color.cgColor
        view?.layer.shadowRadius = radius
        view?.layer.shadowOpacity = Float(opacity)
        view?.layer.shadowOffset = offset
    }
    
    func removeShadow(view: UIView?) {
        view?.layer.shadowColor = UIColor.clear.cgColor
        view?.layer.shadowRadius = 0.0
        view?.layer.shadowOpacity = 0.0
        view?.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
