//
//  ApplicationRootViewController.swift
//  Drawer_Example
//

import UIKit

class ApplicationRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let left = UIStoryboard(name: "Left", bundle: nil).instantiateInitialViewController()!
        let center = UIStoryboard(name: "Center", bundle: nil).instantiateInitialViewController()!
        
        let drawer = DrawerMenu(center: center, left: left)
        addChild(drawer)
        view.addSubview(drawer.view)
        drawer.didMove(toParent: self)
    }
}
