//
//  AuthenticationManager.swift
//  StarbucksAPI
//
//  Created by Mark Vader on 1/8/16.
//  Copyright © 2016 VaderApps. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

enum AuthenticationError: Error {
    
    case Unknown
    case InvalidURL
    case E500
    
}

protocol PresentLoginScreen {
    
    func presentLoginScreen(url: URL)
    
}

let codeReceivedNotification = "CodeReceivedNotification"

let hashMaker = HashProvider()
let requestPrefix =  "https://test.openapi.starbucks.com/v1"
let starCollectionSegue = "StarCollectionSegue"
let apiKeyPublic = "q8srkjxa94njpygsjgd7sy5q"

let apiKey = "a02j000000KRaayAAD"
let secret = "NKmxUwUN9R3HqrcEneKSMhCQ"
let secretPublic = "CeStyTgE8uTKh7XtASwp3KMF"
let client_id = "raindev"
let loginValue = "markv@mediarain.com"
let password = "titSBa81!"
let redirectURI = "https://s3-us-west-2.amazonaws.com/temple52/redirectLanding.html"
let loginURL = "https://starbucks.com/login/default.aspx"


class AuthenticationManager: NSObject, WKNavigationDelegate, TokenProvider {
    
    static let sharedInstance = AuthenticationManager()
    
    var viewController: UIViewController?
    var tokenStruct = Token(tokenValue: "123")
    var tokenFound: String? {
        didSet {
            if let tokenFound = tokenFound, tokenFound != oldValue {
                tokenStruct = Token(tokenValue: tokenFound)
            }
        }
    }
    var refreshToken: String?
    
    private override init() {
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func token() -> Token {
        return tokenStruct
    }
    
    func authenticate(viewController: UIViewController, handler: ((Token) -> Void)) throws -> Void {
        registerForNotifications()
        let starbucksLoginURLString = "https://testusen.starbucks.com/oauth/authorize?response_type=code&source=oauth&client_id=" + apiKey + "&redirect_uri=" + redirectURI
        guard let starbucksLoginURL =  URL(string: starbucksLoginURLString) else { throw AuthenticationError.InvalidURL }
        UIApplication.shared.openURL(starbucksLoginURL)
    }
    
    func authenticateUserCredentials(viewController: UIViewController, handler: @escaping ((Token) -> Void)) -> Void {
        registerForNotifications()
        let timeSince1970 = Int(NSDate().timeIntervalSince1970).description
        let hashMakerInput = apiKey + secret + timeSince1970
        let sig = hashMaker.md5(string: hashMakerInput)
        let starbucksLoginURLString = "https://test.openapi.starbucks.com/v1/oauth/token?sig=" + sig
        let headers = ["Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json", "X-Api-Key": apiKey]
        let parameters = ["grant_type": "password", "client_id": apiKey, "client_secret": secret, "username": "kevinus@me.com", "password": "Abc123"]
        
        guard let alamoURL =  URL(string: starbucksLoginURLString) else {
            return
        }
//        open func request(_ url: URLConvertible, method: Alamofire.HTTPMethod = default, parameters: Parameters? = default, encoding: ParameterEncoding = default, headers: HTTPHeaders? = default) -> Alamofire.DataRequest

        Alamofire.request(alamoURL).responseJSON { (response) in
            let result = response.result
            if let value = result.value as? [String: AnyObject], let accessToken = value["access_token"] as? String {
                handler(Token(tokenValue: accessToken))
            }
        }
        
    }
    
    func authenticateAppOnly(viewController: UIViewController, handler: @escaping ((Token) -> Void)) -> Void {
        registerForNotifications()
        let timeSince1970 = Int(NSDate().timeIntervalSince1970).description
        let hashMakerInput = apiKey + secret + timeSince1970
        let sig = hashMaker.md5(string: hashMakerInput)
        let starbucksLoginURLString = "https://test.openapi.starbucks.com/v1/oauth/token?sig=" + sig
        let headers = ["Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json", "X-Api-Key": apiKey]
        let parameters = ["grant_type": "client_credentials", "client_id": apiKey, "client_secret": secret]
        
        guard let alamoURL =  URL(string: starbucksLoginURLString) else {
            return
        }
        
        Alamofire.request(alamoURL).responseJSON { (response) in
            let result = response.result
            if let value = result.value as? [String: AnyObject], let accessToken = value["access_token"] as? String {
                handler(Token(tokenValue: accessToken))
            }
        }
    }
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: "handleCodeReceivedNotification:", name: NSNotification.Name(rawValue: codeReceivedNotification), object: nil)
    }

    func handleCodeReceivedNotification(notification: NSNotification) {
        let alertController = UIAlertController(title: "connected", message: "connected", preferredStyle: .alert)
        viewController!.present(alertController, animated: true, completion: nil)
        if let userInfo = notification.userInfo {
            if let code = userInfo["code"] as? String {
                makeTokenRequestWithCode(code: code)
            }
        }
    }
    
    func makeTokenRequestWithCode(code: String) {
        viewController?.dismiss(animated: true, completion: nil)
        registerForNotifications()
        let timeSince1970 = Int(NSDate().timeIntervalSince1970).description
        let hashMakerInput = apiKey + secret + timeSince1970
        let sig = hashMaker.md5(string: hashMakerInput)
        guard let alamoURL =  URL(string: "https://test.openapi.starbucks.com/v1/oauth/token?sig=" + sig) else {
            return
        }
        let headers = ["Accept": "application/json", "Content-Type": "application/x-www-form-urlencoded", "X-Api-Key": apiKey]
        let parameters = ["grant_type": "authorization_code", "client_id": apiKey, "client_secret": secret, "code": code, "redirect_uri": redirectURI]
        Alamofire.request(alamoURL).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let myDictionary = response.result.value as? [String: String], let token =  myDictionary["access_token"], let refreshToken =  myDictionary["refresh_token"]  {
                    self.tokenFound = token
                    self.refreshToken = refreshToken
                }
            }
        }
    }
    
}
