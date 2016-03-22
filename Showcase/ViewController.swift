//
//  ViewController.swift
//  Showcase
//
//  Created by Tbakhi on 3/20/16.
//  Copyright © 2016 Tbakhi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton!) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            
            if facebookError != nil {
                
                print("Facebook login failed. Error \(facebookError)")
                
            } else {
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook" , token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        
                        print("Login failed. \(error)")
                        
                    } else {
                        
                        print("Logged in\(authData)")
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                    
                    
                    
                })
            }
        }
        
        
    }
    
    @IBAction func attemptLogin(sender:UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                
                
                if error != nil {
                    
                    print(error)
                    
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            if error != nil {
                                
                                self.showErrorAlert("Could not create Account", msg: "Problem creating account. Try something else")
                                
                            } else {
                                
                                NSUserDefaults.standardUserDefaults().setValue(result [KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN
                                    , sender: nil)
                            }
                            
                        })
                    } else {
                        
                        self.showErrorAlert("Could not login", msg: "Please check user name or password")
                    }
                    
                    
                } else {
                    
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
                
                
                
            })
            
            
        } else {
            
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
        
    }
    
        func showErrorAlert(title:String, msg:String) {
            
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            
            
            presentViewController(alert, animated: true, completion: nil)
            
            
        }
        
        
    }




