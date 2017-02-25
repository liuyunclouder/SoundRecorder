//
//  ViewController.swift
//  SoundRecorder
//
//  Created by TangYunfei on 2017/2/23.
//  Copyright © 2017年 dtstack.com. All rights reserved.
//

import UIKit

private let EZ_BUTTON_SIZE = (width: CGFloat(100.0), height: CGFloat(100.0))

class ViewController: UIViewController, EZAudioManagerDelegate {

    private let audioManager = EZAudioManager()
    private var isRecording = false
    private var recordButton:UIButton?
    private var playButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "录音"
        self.view.backgroundColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "历史录音", style: .plain, target: self, action: #selector(goToRecordList))
        
        self.recordButton = self.assembleRecordButton()
        self.view.addSubview(self.recordButton!)
        self.playButton = self.assemblePlayButton()
        self.view.addSubview(self.playButton!)
        
        
        self.audioManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.playButton?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.audioManager.stopPlay()
    }
    
    func assembleRecordButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: EZ_BUTTON_SIZE.width, height: EZ_BUTTON_SIZE.height)
        button.center = self.view.center
        button.layer.cornerRadius = CGFloat(EZ_BUTTON_SIZE.width / 2.0)
        button.setTitle("Record", for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.backgroundColor = UIColor.green
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action:#selector(longPressRecordButton(sender:)))
        button.addGestureRecognizer(longPressGesture)
        return button
    }
    
    func assemblePlayButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: EZ_BUTTON_SIZE.width, height: EZ_BUTTON_SIZE.height)
        button.center = CGPoint(x: self.view.center.x, y:self.view.center.y + EZ_BUTTON_SIZE.height)
        button.layer.cornerRadius = CGFloat(EZ_BUTTON_SIZE.width / 2.0)
        button.setTitle("Play", for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.backgroundColor = UIColor.yellow
        button.addTarget(self, action:#selector(startPlayButtonPressed), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func longPressRecordButton(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            
            self.audioManager.startRecord()
            print("recording start")
            
        } else if sender.state == UIGestureRecognizerState.ended {
            
            let url = self.audioManager.stopRecord()
            
            if url == nil {
                return
            }
            
            let name = self.nameForFile(with: url!)
            EZDataManager().save(with: name, url: url!.absoluteString)
            print("recording end")
            
            self.playButton?.isHidden = false
            
        }
    }
    
    func nameForFile(with url:URL) -> String {
        var result = "defaultRecordName"
        
        let arr = url.lastPathComponent.components(separatedBy: ".")
        if arr.count > 0 {
            result = arr[0]
        }
        return result
    }

    func startPlayButtonPressed() {
        self.audioManager.startPlay(with: nil)
    }
    
    func goToRecordList () {
        let recordListVC = EZRecordListViewController()
        self.navigationController?.pushViewController(recordListVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - EZAudioManagerDelegate
    func audioPlayerDidFinishPlaying(successfully flag: Bool) {
        print("finish playing")
    }


}

