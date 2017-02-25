//
//  EZDataManager.swift
//  SoundRecorder
//
//  Created by TangYunfei on 2017/2/23.
//  Copyright © 2017年 dtstack.com. All rights reserved.
//

import Foundation
import UIKit



public class EZDataManager {
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    public func save(with name: String, url: String) {
        
        let record = Record(context: self.context)
        record.name = name
        record.url = url
        
        self.appDelegate.saveContext()
        
    }
    
    public func list(completion: @escaping (_ result: [Record]) -> Void){
        
        
        DispatchQueue.global().async {
            let result = self.listSync()
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
    }
    
    public func deleteAll() -> Bool {
        let result: [Record] = self.listSync()
        
        for item in result {
            self.context.delete(item)
        }
        
        self.appDelegate.saveContext()
        
        return true
        
    }
    
    private func listSync() -> [Record] {
        var result: [Record] = []
        
        do {
            result = try self.context.fetch(Record.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
        
        return result
    }
    
    
}
