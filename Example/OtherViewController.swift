//
//  OtherViewController.swift
//  Drawer_Example
//

import UIKit
import DrawerMenu

class OtherViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawer()?.panGestureType = .pan
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        drawer()?.panGestureType = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        navigationController?.pushViewController(vc, animated: true)
    }
}
