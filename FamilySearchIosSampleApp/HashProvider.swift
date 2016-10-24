//
//  HashProvider.swift
//  StarbucksAPI
//
//  Created by Mark Vader on 12/15/15.
//  Copyright © 2015 VaderApps. All rights reserved.
//

import Foundation

protocol HashMaker {
    
    func md5(string: String) -> String
    
}

struct HashProvider {
    
    func md5(string: String) -> String {
//        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
//        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
//            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
//        }
//        
//        let digestHex = digest.reduce("") {
//            (accumulated: String, element: UInt8) -> String in
//            let nextThing =  String(format: "%02x", element)
//            return accumulated + nextThing
//        }
//        
        
      //  return digestHex
        return ""
    }
    
}
