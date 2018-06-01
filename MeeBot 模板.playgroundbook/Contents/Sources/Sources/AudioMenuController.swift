//
//  AudioMenuController.swift
//  PlaygroundScene
//
//  Created by Chao He on 2017/2/28.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//

import UIKit
import MediaPlayer

protocol AudioMenuControllerDelegate {
    
    func enableAudioMenuSelect(_ isEnabled: Bool)
    
    func audioTableviewCellisSelect(index: Int)
}

protocol AudioMenuMusicPickerDelegate {
    
    func mediaPickerDidPickMediaItem(mediaItemCollection:MPMediaItemCollection)
}


// MARK: TableView height
fileprivate let kTableViewHeaderHeight = 40
fileprivate let kTableViewCellHeight = 44
fileprivate let kTableViewFooterHeight = 50


// MARK: Key
let MusicFromLibKey = "MusicFromLib"

class AudioMenuController: UITableViewController {
    var willPlaySongName: String?
    
    // MARK: Properties
    static let cellIdentifier = "AudioTableViewCell"
    
    static let cellIdentifierEnableMusic = "AudioTableViewEnableMusicCell"
    
    static let cellIdentifierChooseYourOwnSong = "AudioTableViewChooseYourOwnSongCell"
    
    fileprivate var lastIndexPath: IndexPath?
    
    fileprivate var tableViewHeight: Int?
    
    /// Music dropdown list
    var dataArray = [String]()
    
    /// Table title
    var tableTitle: String?
    
    // Delegate for select row and  music select callback
    var menuDelegate: AudioMenuControllerDelegate?
    var menuMusicPickerDelegate: AudioMenuMusicPickerDelegate?
    
    // Music menu switch
    var isMenuOpened: Bool?
    
    var myOwnSongHasBPM: Bool = false
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.willPlaySongName != nil {
            Persisted.isBackgroundAudioEnabled = true
        }
        
        /// get background audio state, on or off
        isMenuOpened = Persisted.isBackgroundAudioEnabled
        

        /// table view height
        tableViewHeight = kTableViewHeaderHeight + kTableViewCellHeight * dataArray.count + kTableViewFooterHeight + 30
        
        /// table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: AudioMenuController.cellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: AudioMenuController.cellIdentifierEnableMusic)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: AudioMenuController.cellIdentifierChooseYourOwnSong)
        
        self.title = NSLocalizedString("Music", comment: "title of popover")
        
        liveLog(willPlaySongName)
            
        if self.willPlaySongName != nil {
            liveLog(dataArray[0])

            guard let i = self.dataArray.index(of: self.willPlaySongName!) else {
                return
            }
            liveLog("willPlaySongName action")
            let index = IndexPath(row: i, section: 1)
            self.tableView(self.tableView, didSelectRowAt: index)

            self.menuDelegate?.enableAudioMenuSelect(true)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.preferredContentSize = CGSize(width: 250, height: self.tableView.contentSize.height)
        }

        guard let musicMenuOpen = self.isMenuOpened else {
            return
        }
        if musicMenuOpen {
            setTableViewCellDefaultSelected()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.preferredContentSize = CGSize(width: 250, height: self.tableView.contentSize.height)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: control action
    func switchControlAction(_ switchContrl: UISwitch) {
    
        if switchContrl.isOn {
            setTableViewCellDefaultSelected()
        }
        
        isMenuOpened = switchContrl.isOn
        
        self.menuDelegate?.enableAudioMenuSelect(switchContrl.isOn)
        
        if let navigationController = self.navigationController {
            navigationController.preferredContentSize = CGSize(width: 250, height: self.tableView.contentSize.height)
        }

    }
    
    // MARK: Audio add action
    func addMusicFromLib() {
    
        if MPMediaLibrary.authorizationStatus() == .authorized {
            // success:
            self.authorizedBlock()
            
        } else {
            
            MPMediaLibrary.requestAuthorization({ (status) in

                switch status {
                case .authorized:
                    
                    // success:
                    self.authorizedBlock()
                    
                case .denied: fallthrough
                case .notDetermined: fallthrough
                case .restricted:
                    
                    // failed
                    self.unAuthorizedBlock()
                }
            })
        }
    }
    
    func authorizedBlock() {

        showMediaPickerController()
    }
    
    func unAuthorizedBlock() {
    
    }
    
    // show Media picker
    func showMediaPickerController() {
        
        let mpc = MPMediaPickerController(mediaTypes: .anyAudio)
        mpc.delegate = self as MPMediaPickerControllerDelegate
        //mpc.prompt = "Please select a music"
        mpc.allowsPickingMultipleItems = false
        
        self.present(mpc, animated: true, completion: nil)
    }
    
    func dismissMediaPickerController() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Internal Methods
    func setTableViewCellDefaultSelected(index: Int =  Persisted.backgroudAudioSelectedIndex) {
        
        var newIndex = index
        
        if Persisted.isLastLesson {
            Persisted.backgroudAudioSelectedIndex = index
        } else {
            Persisted.backgroudAudioSelectedIndex = (index < 2) ? index : 0
            newIndex = Persisted.backgroudAudioSelectedIndex
        }
        
        newIndex = Persisted.backgroudAudioSelectedIndex

        let defaultIndexPath = IndexPath(row: Int(newIndex), section: 1)
        let firstCell = tableView.cellForRow(at: defaultIndexPath)
        firstCell?.accessoryType = .checkmark
        firstCell?.textLabel?.textColor = UIColor.orange
        firstCell?.detailTextLabel?.textColor = UIColor.orange
        
        lastIndexPath = defaultIndexPath
    }
    
    // selected cell
    func setTableViewCellSelected(index: Int) {
        
        let selectedIndexPath = IndexPath(row: Int(index), section: 1)
        let firstCell = tableView.cellForRow(at: selectedIndexPath)
        
        firstCell?.accessoryType = .checkmark
        firstCell?.textLabel?.textColor = UIColor.orange
        firstCell?.detailTextLabel?.textColor = UIColor.orange
        
        lastIndexPath = selectedIndexPath
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if Persisted.isLastLesson {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount : Int = 0;
        switch section {
        case 0:
            rowCount = 1;
            break
        case 1:
            rowCount = dataArray.count;
            break
        case 2:
            rowCount = 1;
            break
        default:
            break
        }
        return rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: AudioMenuController.cellIdentifierEnableMusic, for: indexPath)
            
            let switchControl = UISwitch(frame: CGRect(x: 180, y: 5, width: 70, height: kTableViewHeaderHeight))

            cell.accessoryView = switchControl
            switchControl.addTarget(self, action: #selector(switchControlAction(_:)), for: .valueChanged)
            switchControl.isOn = isMenuOpened!

            cell.selectionStyle = .none
            
            cell.textLabel?.text = NSLocalizedString("Play Music", comment: "cell in the music selection popover")
        
            return cell

            break
            
        case 1:
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: AudioMenuController.cellIdentifier)
            
            let currentRow = indexPath.row
            let lastRow = lastIndexPath?.row
            
            if currentRow == lastRow && (lastIndexPath != nil){
                cell.accessoryType = .checkmark
                cell.textLabel?.textColor = UIColor.orange
                cell.detailTextLabel?.textColor = UIColor.orange
            }
            else {
                cell.accessoryType = .none
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.gray
            }
            cell.selectionStyle = .none
            
            /// music name
            cell.textLabel?.text = dataArray[indexPath.row]
            
            /// bmpValue
            var curentBPM = UInt(0)
            switch indexPath.row {
            case 0:
                curentBPM = 60
                break
            case 1:
                curentBPM = 120
                break
            case 2:
                if self.myOwnSongHasBPM {
                    curentBPM = Persisted.musicBPMFromLib
                }
                else {
                    curentBPM = 0
                }
                break
            default:
                break
            }
            var subtitleText : String
            if curentBPM > 0 {
                subtitleText = String(format: NSLocalizedString("%d BPM", comment: "subtitle for songs in the music selection menu, indicating BPM of that song"), curentBPM)
            }
            else {
                subtitleText = NSLocalizedString("Input BPM", comment: "subtitle for songs in the music selection menu, indicating we cannot find BPM of song automatically.")
            }
            cell.detailTextLabel?.text = subtitleText
            
            return cell
            
            break

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: AudioMenuController.cellIdentifierChooseYourOwnSong, for: indexPath)
            
            cell.selectionStyle = .gray
            
            cell.textLabel?.text = NSLocalizedString("Choose your own song...", comment: "cell in the music selection popover")
            
            return cell
            
            break
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: AudioMenuController.cellIdentifier, for: indexPath)
            
            return cell
            
            break
        }

        
    }
    
    
    // MARK: - Talbe view Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        print("selected row: \(indexPath.row)")
        liveLog("didSelectRowAt")
        
        if (indexPath.section == 1) {
            /// Persisted the current select index
            Persisted.backgroudAudioSelectedIndex = indexPath.row
       
            let newRow = indexPath.row
            let oldRow = (lastIndexPath != nil) ? lastIndexPath?.row : -1
            if newRow != oldRow {
                let newCell = tableView.cellForRow(at: indexPath)
                newCell?.accessoryType = .checkmark
                newCell?.textLabel?.textColor = UIColor.orange
                newCell?.detailTextLabel?.textColor = UIColor.orange
                
                if oldRow != -1 {
                    let oldCell = tableView.cellForRow(at: lastIndexPath!)
                    oldCell?.accessoryType = .none
                    oldCell?.textLabel?.textColor = UIColor.black
                    oldCell?.detailTextLabel?.textColor = UIColor.gray
                }
                
                lastIndexPath = indexPath
//                self.menuDelegate?.audioTableviewCellisSelect(index: indexPath.row)
            }
            self.menuDelegate?.audioTableviewCellisSelect(index: indexPath.row)
        }
        else if (indexPath.section == 2) {
            self.addMusicFromLib()
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
        
        super.init(style: .grouped)
    }
    
    // Update to the lastest selected cell
    func updateSelectedCell(index: Int) {
        
        /// Persisted the current select index
        Persisted.backgroudAudioSelectedIndex = index
        
        setTableViewCellSelected(index: index)
        tableView.reloadData()
    }
}

// MARK: MPMediaPickerControllerDelegate

extension AudioMenuController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        for item in mediaItemCollection.items {
            
            guard let musicName = item.title else {
                return
            }
            print("choosed music:\(musicName)")
            
            // Get current music BPM
            var bmpValue = item.beatsPerMinute
            if bmpValue == 0 {
                bmpValue = 100
                self.myOwnSongHasBPM = false
            } else {
                self.myOwnSongHasBPM = true
            }
            print("\(musicName)'s BPM = \(bmpValue)")
            
            // Persisted choosed music and BPM
            Persisted.musicNameFromLib = musicName
            Persisted.musicBPMFromLib = UInt(bmpValue)
            
            if self.dataArray.count < buildInMusicCount + 1 {
                self.dataArray = self.dataArray + [musicName]
            } else {
                self.dataArray.removeLast()
                self.dataArray.append(musicName)
            }
            
            tableView.reloadData()
        }
        
        self.menuMusicPickerDelegate?.mediaPickerDidPickMediaItem(mediaItemCollection: mediaItemCollection)
        
        dismissMediaPickerController()
        
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
        dismissMediaPickerController()
    }
}
