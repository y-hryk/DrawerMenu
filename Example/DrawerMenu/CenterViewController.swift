//
//  CenterViewController.swift
//  Drawer
//

import UIKit
import DrawerMenu

class CenterViewController: UITableViewController {

    private var selectedStyleRow: Int = 0
    private var selectedGestureRow: Int = 0
    
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
    
    // MARK: Private
    func getStyle(row: Int) -> DrawerMenuStyle {
        if row == 0 { return Slide() }
        if row == 1 { return SlideIn() }
        if row == 2 { return Overlay() }
        if row == 3 { return Parallax() }
        if row == 4 { return Floating() }
        return Slide()
    }
    
    func getGestureType(row: Int) -> DrawerMenu.PanGestureType {
        if row == 0 { return .pan }
        if row == 1 { return .screenEdge }
        if row == 2 { return .none }
        return .pan
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.accessoryType = .none
        if indexPath.section == 0 {
            cell.accessoryType = indexPath.row == selectedStyleRow ? .checkmark : .none
        }
        if indexPath.section == 1 {
            cell.accessoryType = indexPath.row == selectedGestureRow ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let style = getStyle(row: indexPath.row)
            drawer()?.style = style
            selectedStyleRow = indexPath.row
        }
        if indexPath.section == 1 {
            drawer()?.panGestureType = getGestureType(row: indexPath.row)
            selectedGestureRow = indexPath.row
        }
        
        tableView.reloadData()
    }
}

