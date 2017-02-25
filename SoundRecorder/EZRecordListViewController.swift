//
//  EZRecordListViewController.swift
//  SoundRecorder
//
//  Created by TangYunfei on 2017/2/23.
//  Copyright © 2017年 dtstack.com. All rights reserved.
//

import UIKit

private let CELL_REUSE_IDENTIFIER = String(describing: EZTableViewCell.self)

class EZRecordListViewController: UITableViewController, EZTableViewCellDelegate, EZAudioManagerDelegate {
    
    private let audioManager = EZAudioManager()
    private var playingIndexPath: IndexPath?
    private var dataSource:[RecordWithStatus] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "历史录音"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清空", style: .plain, target: self, action: #selector(deleteAllRecords))
        
        self.audioManager.delegate = self
        
        self.tableView.register(EZTableViewCell.self, forCellReuseIdentifier: CELL_REUSE_IDENTIFIER)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchRecordsData { (result: [RecordWithStatus]) in
            self.dataSource = result
            self.tableView.reloadData()
        }
        
        
        
    }
    
    func fetchRecordsData(completion:@escaping (_ result:[RecordWithStatus])->Void){
        
        
        EZDataManager().list { (result: [Record]) in
            var results: [RecordWithStatus] = []
            
            for item in result {
                let recordWithStatus = RecordWithStatus(record: item)
                results.append(recordWithStatus)
            }
            
            completion(results)
        }
        
        
        
    }

    func deleteAllRecords() {
        let dataManager = EZDataManager()
        let isDeleted = dataManager.deleteAll()
        
        if isDeleted {
            self.dataSource = []
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playRecord(at indexPath:IndexPath, playing:Bool) {
        
        if  indexPath.row < self.dataSource.count {
            let dataItem = self.dataSource[indexPath.row]
            
            if playing {
                let url = dataItem.record.url
                
                let audioUrl = URL(string: url!)
                
                self.audioManager.startPlay(with: audioUrl)
            } else {
                self.audioManager.stopPlay()
            }
            
            dataItem.isPlaying = playing
            
            let cell = self.tableView.cellForRow(at: indexPath) as? EZTableViewCell
            cell?.setIsPlaying(isPlaying: dataItem.isPlaying)
        }
    }
    
    func data(at indexPath: IndexPath) -> RecordWithStatus? {
        var result:RecordWithStatus? = nil
        
        
        if  indexPath.row < self.dataSource.count {
            result = self.dataSource[indexPath.row]
        }
        
        return result
    }
    
    // MARK: - EZTableViewCellDelegate
    func playButtonIsClicked(for cell: EZTableViewCell) {
        
        let indexPathToPlay = self.tableView.indexPath(for: cell)
        
        
        if self.playingIndexPath == nil {
            playRecord(at: indexPathToPlay!, playing: true)
            self.playingIndexPath = indexPathToPlay
            return
        }
        
        if self.playingIndexPath != indexPathToPlay {
            playRecord(at: self.playingIndexPath!, playing: false)
            
            playRecord(at: indexPathToPlay!, playing: true)

            self.playingIndexPath = indexPathToPlay
        } else {
            let dataItem = data(at: self.playingIndexPath!)
            
            if dataItem == nil {
                return
            }
            
            if dataItem!.isPlaying {
                
                playRecord(at: self.playingIndexPath!, playing: false)
                

            } else {
                
                playRecord(at: self.playingIndexPath!, playing: true)

            }
        }
        
    }
    
    // MARK: - EZAudioManagerDelegate
    func audioPlayerDidFinishPlaying(successfully flag: Bool) {
        if self.playingIndexPath != nil {
            
            playRecord(at: self.playingIndexPath!, playing: false)
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_IDENTIFIER, for: indexPath) as! EZTableViewCell
        
        
        if  indexPath.row < self.dataSource.count {
            let dataItem = self.dataSource[indexPath.row]
            
            cell.config(data: dataItem)
            
            cell.delegate = self
        }
        
        
        
        return cell
    }
    
}

