//
//  LeftViewController.swift
//  Drawer_Example
//
//  Created by Hiroyuki Yamaguchi on 2019/06/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DrawerMenu

class LeftViewController: UITableViewController {

    private var selectedWidth: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("left menu viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("left menu viewWillDisappear\n")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getController(row: Int) -> UIViewController {
        
        if row == 0 { return UIStoryboard(name: "Center", bundle: nil).instantiateInitialViewController()! }
        if row == 1 { return UIStoryboard(name: "Other", bundle: nil).instantiateInitialViewController()! }
        return UIViewController()
    }
    
    func getWidth(row: Int) -> CGFloat {
        
        if row == 0 { return 200 }
        if row == 1 { return 240 }
        if row == 2 { return 280 }
        if row == 3 { return 320 }
        return view.frame.width * 0.8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.accessoryType = .none
        if indexPath.section == 1 {
            cell.accessoryType = getWidth(row: indexPath.row) == selectedWidth ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            drawer()?.replace(center: getController(row: indexPath.row))
        }
        if indexPath.section == 1 {
            let width = getWidth(row: indexPath.row)
            selectedWidth = width
            drawer()?.leftMenuWidth = width
        }
        tableView.reloadData()
    }
}
