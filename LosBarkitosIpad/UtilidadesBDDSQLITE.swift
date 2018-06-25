//
//  UtilidadesBDDSQLITE.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 27/2/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import Foundation
import UIKit

class UtilidadesBDDSQLITE : NSObject {
    
    class func getPath(_ fileName : String) -> String {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] 
        let path = (documentsFolder as NSString).appendingPathComponent(fileName)
        print(path)
        
        return path
    }
    
    class func copyFile(_ fileName : NSString) {
        let dbPath : String = getPath(fileName as String)

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            let fromPath : String = (Bundle.main.resourcePath as NSString!).appendingPathComponent(fileName as String)
            
            do {
                try fileManager.copyItem(atPath: fromPath, toPath: dbPath)
            } catch _ {
            }
        }
    }
}
