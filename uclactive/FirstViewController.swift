//
//  FirstViewController.swift
//  uclactive
//
//  Created by Diana Darie on 7/16/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit
import HealthKit
import FacebookLogin
import Google
import Alamofire
import SwiftyJSON

var loginUser = ""

class FirstViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    let healthManager:HealthKitManager = HealthKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Facebook Login
        let facebookLogin = LoginButton(readPermissions: [ .PublicProfile ])
        facebookLogin.center = CGPointMake(view.frame.width/2, 450)
        
        //Gmail Login
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError != nil {
            print(configureError)
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let gmailLogin = GIDSignInButton(frame: CGRectMake(0, 0, 180, 10))
        gmailLogin.center = CGPointMake(view.frame.width/2, 500)
        
        view.addSubview(facebookLogin)
        view.addSubview(gmailLogin)
        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print("GMAIL INFO: ")
        print(user.profile.givenName)
        print(user.profile.familyName)
        print(user.profile.email)
        print(user.profile.imageURLWithDimension(400))
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    }
    
    func loginFails(errorMsg: String){
        let alertController = UIAlertController(title: "Login Fails", message: errorMsg, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "Close Window", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var UserName: UITextField!
    
    @IBOutlet weak var PassWord: UITextField!
    
    @IBAction func login(sender: AnyObject) {
        print("Clicked Login Button")
        let url = "http://transpire.azurewebsites.net/loginIOS";
        //let parameters = ["email": "aa@aa.com", "password": "aa"]
        let parameters = ["email": self.UserName.text as! AnyObject, "password": self.PassWord.text as! AnyObject]
        Alamofire
            .request(.POST, url, parameters: parameters, encoding:.JSON)
            .responseJSON{ response in
                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    let response = JSON as! NSDictionary
                    let content = response.objectForKey("loginStatus")!
                    print(content as! String)
                    if (content as! String == "Success") {
                        loginUser = self.UserName.text!
                        let secondViewController:  UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController"))! as UIViewController;
                        self.presentViewController(secondViewController, animated: true, completion: nil)

                    }
                    else {
                        let errorMsg = "Wrong Password or Username"
                        print(errorMsg)
                        self.loginFails(errorMsg);
                    }
                case .Failure(let error):
                    let errorMsg = "Server Error: \(error)"
                    print(errorMsg)
                    self.loginFails("Wrong Password or Username");
                }
        }
    }
}

