//
//  LoginVC.swift
//  FamilySearchIosSampleApp
//
//  Created by Eduardo Flores on 6/3/16.
//  Copyright © 2016 FamilySearch. All rights reserved.
//

import UIKit
import SafariServices
// com.vaderapps.familysearch

class LoginVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dataUsageLabel: UILabel!
    let authenticationManager = AuthenticationManager.sharedInstance

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unlockScreen()
        
        usernameTextField.placeholder = NSLocalizedString("usernamePlaceholderText", comment: "username, in email form")
        passwordTextField.placeholder = NSLocalizedString("passwordPlaceholderText", comment: "password")
        loginButtonOutlet.setTitle(NSLocalizedString("loginText", comment: "text for login button"), for: UIControlState())
        dataUsageLabel.text = NSLocalizedString("loginDataUsage", comment: "description of data usage")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openURL(_ sender: UIButton) {
        
        let familySearchLoginURLString = "https://sandbox.familysearch.org/cis-web/oauth2/v3/authorization?response_type=code&source=oauth&client_id=" + apiKey + "&redirect_uri=" + redirectURI
        guard let familySearchLoginURL = URL(string: familySearchLoginURLString) else { return }
        
        let safariVC = SFSafariViewController(url: familySearchLoginURL)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: AnyObject)
    {
        lockScreen()
        
        guard let
            username = usernameTextField.text,
            let password = passwordTextField.text
            , !username.isEmpty && !password.isEmpty
            else {
                self.showAlert("Error", description: "User name or password missing")
                unlockScreen()
                return
        }
        
        // get initial GET call to collections
        Utilities.getUrlsFromCollections({ [weak self] (collectionsResponse, error) -> Void in
            
            guard error == nil else {
                print("Error getting collections data from server. Error = \(error?.description)")
                self?.activityIndicator.stopAnimating()
                return
            }
            
            // get the login token
            if #available(iOS 10.0, *) {
                self?.getToken(collectionsResponse.tokenUrlString!,
                               username: username,
                               password: password,
                               client_id: AppKeys.API_KEY,
                               completionToken: {(responseToken, errorToken) -> Void in
                                guard errorToken == nil else {
                                    DispatchQueue.main.async(execute: {
                                        self!.showAlert("Error", description: errorToken!.localizedDescription)
                                        self!.unlockScreen()
                                    })
                                    
                                    return
                                }
                                
                                // get user data, with the newly acquired token
                                self?.getCurrentUserData(collectionsResponse.currentUserString!,
                                                         accessToken: responseToken!,
                                                         completionCurrentUser:{(responseUser, errorUser) -> Void in
                                                            guard errorToken == nil else {
                                                                DispatchQueue.main.async(execute: {
                                                                    self!.showAlert("Error", description: errorToken!.localizedDescription)
                                                                    self!.unlockScreen()
                                                                })
                                                                return
                                                            }
                                                            // all login data needed has been downloaded
                                                            // push to the next view controller, in the main thread
                                                            DispatchQueue.main.async(execute: {
                                                                [weak self] in
                                                                self?.performSegue(withIdentifier: "segueToTabBar", sender: responseUser)
                                                                })
                                })
                                
                    }
                )
            } else {
                // Fallback on earlier versions
            }
            })
    }
    
    @available(iOS 10.0, *)
    func getToken(_ tokenUrlAsString : String, username : String, password : String, client_id : String, completionToken:@escaping (_ responseToken:String?, _ errorToken:NSError?) -> ()) {
        let grant_type = "password";
        
        
        let familySearchLoginURLString = "https://sandbox.familysearch.org/cis-web/oauth2/v3/authorization?response_type=code&source=oauth&client_id=" + apiKey + "&redirect_uri=" + redirectURI
        guard let familySearchLoginURL = URL(string: familySearchLoginURLString) else { return }
        UIApplication.shared.open(familySearchLoginURL, options: [:]) { success in
            
            
            print(success)
            
            
            
            
            print("Here is anser \(success)")
            
            
            let a = 123
            
            
            
            let g = 1234
        }  //openURL(familySearchLoginURL)
        //
        //        // create the post request
        //        let request = NSMutableURLRequest(url: URL(string: familySearchLoginURLString)!)
        //
        //        request.httpMethod = "POST"
        //
        //        let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
        //            print("Data is \(data)")
        //
        //            guard error == nil else {
        //                print("Error downloading token. Error: \(error)")
        //                completionToken(nil, error as NSError?)
        //                return
        //            }
        //            do  {
        //                guard let jsonToken = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject] else {
        //                    return
        //                }
        //
        //                if let error = jsonToken["error"] as? String
        //                {
        //                    let description = jsonToken["error_description"] as? String
        //                    print("\(error) \(description)")
        //
        //                    let userInfo = [NSLocalizedDescriptionKey : description!]
        //                    completionToken(nil, NSError(domain: "FamilySearch", code: 1, userInfo: userInfo))
        //                }
        //
        //                if let token = jsonToken["access_token"] as? String
        //                {
        //                    // parse the json to get the access_token, and save this token in NSUserDefaults
        //                    let preferences = UserDefaults.standard
        //                    preferences.setValue(token, forKey: Utilities.KEY_ACCESS_TOKEN)
        //                    preferences.synchronize()
        //
        //                    completionToken(token, nil)
        //                }
        //            }
        //            catch {
        //                print("Error: \(error)");
        //            }
        
        //  }
        
        // task.resume()
    }
    
    // get the user data
    func getCurrentUserData(_ currentUserUrlString : String, accessToken : String, completionCurrentUser:@escaping (_ responseUser:User?, _ errorUser:NSError?) -> ())
    {
        let currentUserUrl = URL(string: currentUserUrlString);
        
        let configuration = URLSessionConfiguration.default;
        let headers: [AnyHashable: Any] = ["Accept":"application/json", "Authorization":"Bearer " + accessToken];
        configuration.httpAdditionalHeaders = headers;
        let session = URLSession(configuration: configuration)
        
        let currentUserTask = session.dataTask(with: currentUserUrl!, completionHandler: { (data, currentUserResponse, errorUserData) in
            // parse the currentUser data
            do
            {
                guard let currentUserJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject] else {
                    return
                }
                
                if let usersJsonObject = currentUserJson["users"] as? [[String : AnyObject]]
                {
                    let user = User()
                    
                    if let userJsonObject = usersJsonObject.first
                    {
                        user.id = userJsonObject["id"] as? String
                        user.contactName = userJsonObject["contactName"] as? String
                        user.helperAccessPin = userJsonObject["helperAccessPin"] as? String
                        user.givenName = userJsonObject["givenName"] as? String
                        user.familyName = userJsonObject["familyName"] as? String
                        user.email = userJsonObject["email"] as? String
                        user.country = userJsonObject["country"] as? String
                        user.gender = userJsonObject["gender"] as? String
                        user.birthDate = userJsonObject["birthDate"] as? String
                        user.phoneNumber = userJsonObject["phoneNumber"] as? String
                        user.mailingAddress = userJsonObject["mailingAddress"] as? String
                        user.preferredLanguage = userJsonObject["preferredLanguage"] as? String
                        user.displayName = userJsonObject["displayName"] as? String
                        user.personId = userJsonObject["personId"] as? String
                        user.treeUserId = userJsonObject["treeUserId"] as? String
                        
                        // The Memories activity will need the URL that comes from user.links.artifact.href
                        // in order to get the memories data
                        let links = userJsonObject["links"] as? NSDictionary
                        let artifacts = links!["artifacts"] as? NSDictionary
                        user.artifactsHref = artifacts!["href"] as? String
                        
                        completionCurrentUser(user, nil)
                        
                        return
                    }
                    else
                    {
                        print("The user JSON does not contain any data")
                    }
                    
                    completionCurrentUser(nil, nil)
                }
                
            }
            catch
            {
                completionCurrentUser(nil, errorUserData as NSError?)
            }
        })
        currentUserTask.resume()
        
    }
    
    // MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "segueToTabBar")
        {
            let tabBarController : UITabBarController = (segue.destination as? UITabBarController)!
            tabBarController.tabBar.items![0].title = NSLocalizedString("tabAncestorsName", comment: "name for list tab")
            tabBarController.tabBar.items![1].title = NSLocalizedString("tabMemoriesName", comment: "name for memories tab")
            
            guard let treeTVC = tabBarController.viewControllers?[0] as? TreeTVC else {
                fatalError("The first viewController in the tabBarController should be an instance of TreeTVC")
            }
            // need to pass a User object to the tree table view controller
            treeTVC.user = sender as? User
            
            guard let memoriesVC = tabBarController.viewControllers?[1] as? MemoriesVC else {
                fatalError("The second viewController in the tabBarController should be an instance of MemoriesVC")
            }
            memoriesVC.user = sender as? User
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Private methods
    fileprivate func lockScreen() {
        usernameTextField.isEnabled = false
        passwordTextField.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    fileprivate func unlockScreen() {
        usernameTextField.isEnabled = true
        passwordTextField.isEnabled = true
        activityIndicator.stopAnimating()
    }
}




extension LoginVC: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


































