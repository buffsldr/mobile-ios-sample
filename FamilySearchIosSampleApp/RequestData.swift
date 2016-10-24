//
//  ResponseData.swift
//  Pods
//
//  Created by Mark Vader on 10/22/16.
//
//

import Foundation
import Alamofire

struct RequestData {
    
    let headers: [String: String]
    let parameters: [String: String]
    let url: URL
    let method: Alamofire.HTTPMethod

    
}
