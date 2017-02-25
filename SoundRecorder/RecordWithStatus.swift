//
//  RecordWithStatus.swift
//  SoundRecorder
//
//  Created by TangYunfei on 2017/2/23.
//  Copyright © 2017年 dtstack.com. All rights reserved.
//

import Foundation

class RecordWithStatus {
    let record: Record
    var isPlaying: Bool = false
    
    init(record: Record) {
        self.record = record
    }
}
