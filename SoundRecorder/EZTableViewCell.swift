//
//  EZTableViewCell.swift
//  SoundRecorder
//
//  Created by TangYunfei on 2017/2/23.
//  Copyright © 2017年 dtstack.com. All rights reserved.
//

import UIKit



protocol EZTableViewCellDelegate: class {
    func playButtonIsClicked(for cell: EZTableViewCell)
}


//TODO：移到consts中
let SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.size.height

private let EZ_BUTTON_SIZE = (width: CGFloat(60.0), height: CGFloat(44.0))



class EZTableViewCell: UITableViewCell {
    
    private var nameLabel: UILabel!
    private var playButton: UIButton!
    weak var delegate:EZTableViewCellDelegate?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.nameLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 44))
        
        self.playButton = self.assemblePlayButton()
        
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.playButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func config(data: RecordWithStatus) {
        
        let name = data.record.name
        nameLabel.text = name
        
        
        self.setIsPlaying(isPlaying: data.isPlaying)
        
    }
    
    func assemblePlayButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: SCREEN_WIDTH - EZ_BUTTON_SIZE.width, y: 0, width: EZ_BUTTON_SIZE.width, height: EZ_BUTTON_SIZE.height)
        button.setTitle("play", for: UIControlState.normal)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        button.backgroundColor = UIColor.yellow
        button.addTarget(self, action:#selector(startPlayButtonPressed), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func setIsPlaying (isPlaying: Bool) {
        
        if isPlaying {
            self.playButton.setTitle("playing", for: UIControlState.normal)
            self.contentView.backgroundColor = UIColor.red
        } else {
            self.playButton.setTitle("play", for: UIControlState.normal)
            self.contentView.backgroundColor = UIColor.clear
        }
    }
    
    func startPlayButtonPressed() {
        self.delegate?.playButtonIsClicked(for:self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
