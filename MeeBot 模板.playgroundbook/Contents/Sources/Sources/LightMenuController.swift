//
//  LightMenuController.swift
//  PlaygroundScene
//
//  Created by Chao He on 2017/3/2.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//

import UIKit

protocol LightMenuControllerDelegate {
    
    func enableLightMenuSelect(_ isEnabled: Bool)
    
    func lightTableviewCellisSelect(index: Int)
}


// MARK: TableView height
fileprivate let kTableViewHeaderHeight = 40
fileprivate let kTableViewCellHeight = 44


class LightMenuController: UITableViewController {
    
    // MARK: Properties
    static let cellIdentifier = "LightTableViewCell"
    
    fileprivate var lastIndexPath: IndexPath?
    
    fileprivate var tableViewHeight: Int?
    
    /// data
    var dataArray = [String]()
    
    /// table title
    var tableTitle: String?
    
    var menuDelegate: LightMenuControllerDelegate?
    
    var isMenuOpened: Bool?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// get background Light state, on or off
        isMenuOpened = Persisted.isBackgroundLightEnabled
        
        /// table view height
        tableViewHeight = kTableViewHeaderHeight + kTableViewCellHeight * dataArray.count
        
        /// table view
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: LightMenuController.cellIdentifier)
        if isMenuOpened! {
            preferredContentSize = CGSize(width: 250, height: tableViewHeight!)
        } else {
            preferredContentSize = CGSize(width: 250, height: kTableViewHeaderHeight)
        }
        
        // header view
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: kTableViewHeaderHeight))
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 100, height: kTableViewHeaderHeight))
        titleLabel.text = tableTitle
        headerView.addSubview(titleLabel)
        
        let switchControl = UISwitch(frame: CGRect(x: 180, y: 5, width: 70, height: kTableViewHeaderHeight))
        headerView.addSubview(switchControl)
        switchControl.addTarget(self, action: #selector(switchControlAction(_:)), for: .valueChanged)
        switchControl.isOn = isMenuOpened!
        
        tableView.tableHeaderView = headerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMenuOpened! {
            setTableViewCellDefaultSelected()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: control action
    func switchControlAction(_ switchContrl: UISwitch) {
        //
        if switchContrl.isOn {
            preferredContentSize = CGSize(width: 250, height: tableViewHeight!)
            setTableViewCellDefaultSelected()
        } else {
            preferredContentSize = CGSize(width: 250, height: kTableViewHeaderHeight)
        }
        
        self.menuDelegate?.enableLightMenuSelect(switchContrl.isOn)
        
    }
    
    // MARK: - Internal Methods
    func setTableViewCellDefaultSelected(index: Int =  Persisted.backgroudLightSelectedIndex) {
        
        Persisted.backgroudLightSelectedIndex = index
        
        let defaultIndexPath = IndexPath(row: Int(index), section: 0)
        let firstCell = tableView.cellForRow(at: defaultIndexPath)
        firstCell?.accessoryType = .checkmark
        firstCell?.textLabel?.textColor = UIColor.red
        
        lastIndexPath = defaultIndexPath
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LightMenuController.cellIdentifier, for: indexPath)
        
        let currentRow = indexPath.row
        let lastRow = lastIndexPath?.row
        
        if currentRow == lastRow && (lastIndexPath != nil){
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.red
        }
        else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
        }
        
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 17)
        
        cell.textLabel?.text = dataArray[indexPath.row]
        
        return cell
    }
    
    
    // MARK: - Talbe view Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        print("selected row: \(indexPath.row)")
        
        /// Persisted the current select index
        Persisted.backgroudLightSelectedIndex = indexPath.row
        
        let newRow = indexPath.row
        let oldRow = (lastIndexPath != nil) ? lastIndexPath?.row : -1
        if newRow != oldRow {
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark
            newCell?.textLabel?.textColor = UIColor.red
            
            if oldRow != -1 {
                let oldCell = tableView.cellForRow(at: lastIndexPath!)
                oldCell?.accessoryType = .none
                oldCell?.textLabel?.textColor = UIColor.black
            }
            
            lastIndexPath = indexPath
            
            self.menuDelegate?.lightTableviewCellisSelect(index: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Initializtion
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(tableTitle: String, dataArray:[String]){
        
        self.tableTitle = tableTitle
        self.dataArray = dataArray
        self.isMenuOpened = false
        
        super.init(style: .plain)
    }
}
