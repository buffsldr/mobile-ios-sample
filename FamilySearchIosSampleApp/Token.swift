//
//  Token.swift
//  StarbucksAPI
//
//  Created by Mark Vader on 1/8/16.
//  Copyright © 2016 VaderApps. All rights reserved.
//

import Foundation
import Alamofire

struct Token {
    
    let tokenValue: String
    
}



struct NewUser: CreateAccount, RequestDataForRequestType {
    
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let registrationSource: String
    let countryCode: String
    
}

struct History: GetOrderHistoryByUser, RequestDataForRequestType {
    
    let dateSince: Date
    
    func ifModifiedSinceDate() -> Date {
        return dateSince
    }
 
}

class Cart: NSObject {
    
    
}

protocol TokenProvider {
    
    func token() -> Token
    
}

protocol RequestDataForRequestType {
    
    func data(token: Token) -> RequestData
    
}

let baseURLString = "https://test.openapi.starbucks.com/v1"

extension RequestDataForRequestType where Self: CreateAccount {
    
    func data(token: Token) -> RequestData {
        let parameters: [String: String] = ["emailAddress": self.email, "password": self.password, "firstName": self.firstName, "lastName": self.lastName, "registrationSource":  "myMobileApp" ]
        let headers = ["Accept": "application/json", "Content-Type": "application/json"]
        let url = URL(string: baseURLString + "/me/cards/history?access_token=" + token.tokenValue)!

        return RequestData(headers: headers, parameters: parameters, url: url, method: .get)
    }
  
}

extension RequestDataForRequestType where Self: GetOrderHistoryByUser {
    
    func data(token: Token) -> RequestData {
        let dateString = DateFormatter.localizedString(from: ifModifiedSinceDate(), dateStyle: .full, timeStyle: .full)
        let parameters: [String: String] = ["": ""]
        let headers = ["Accept": "application/json", "Content-Type": "application/json", "If-Modified-Since": dateString]
        let url = URL(string: baseURLString + "/me/cards/history?access_token=" + token.tokenValue)!
        
        return RequestData(headers: headers, parameters: parameters, url: url, method: .get)
    }
    
}

extension RequestDataForRequestType where Self: GetProductStatus {
    
    func data(token: Token) -> RequestData {
        let parameters: [String: String] = [:]
        let headers = ["Accept": "application/json", "Content-Type": "application/json"]
        let url = URL(string: baseURLString + "/products/status/" + storeNumber().description + "?serviceType=yes&access_token=" + token.tokenValue)!
        
        return RequestData(headers: headers, parameters: parameters, url: url, method: .get)
    }
    
}


protocol CreateAccount {
    
    var firstName: String { get }
    var lastName: String { get }
    var email: String { get }
    var password: String { get }
    var registrationSource: String { get }
    var countryCode: String { get }
    
}

protocol GetOrderHistoryByUser {
    
    func ifModifiedSinceDate() -> Date
    
}

protocol GetProductStatus {
    
    func cart() -> Cart
    func storeNumber() -> Int
    
}

enum RequestType {
    case CreateAccount
    case GetOrderHistoryByUser
    case GetProductStatus
    case GetOrderStorePricingByItemList
    case GetProductsInCatalog
    case GetCardBalance
    case GetStore
    case GetPaymentMethods
    case UpdatePaymentMethod
    case ReloadCard
    case SubmitOrderToStore
}



class RequestMaker: NSObject {

    let tokenProvider: TokenProvider
    let requestDataForRequestType: RequestDataForRequestType
    let data: RequestData
    
    init(tokenProvider: TokenProvider, requestDataForRequestType: RequestDataForRequestType) {
        self.tokenProvider = tokenProvider
        self.requestDataForRequestType = requestDataForRequestType
        self.data = requestDataForRequestType.data(token: tokenProvider.token())
        super.init()
    }
    
    func provideRequest() -> Request {
        return Alamofire.request(data.url)
    }
    
}
