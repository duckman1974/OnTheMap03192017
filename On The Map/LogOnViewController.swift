//
//  LogOnViewController.swift
//  On The Map
//
//  Created by Candice Reese on 3/12/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import UIKit

class LogOnViewController: UIViewController, UITextFieldDelegate {
    
    
    var session: URLSession!
    var appDelegate: AppDelegate!
    
    
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var logInText: UILabel!
    @IBOutlet weak var udacityImage: UIImageView!
    @IBOutlet weak var statusWheel: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = URLSession.shared
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.userName.delegate = self
        self.passWord.delegate = self
        statusWheel.isHidden = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.statusWheel.stopAnimating()
        self.statusWheel.isHidden = true
    }
    
    
    
    
    @IBAction func logIn(_ sender: AnyObject) {
        
        let email = userName.text!
        let password = passWord.text!
        
        if ((email.isEmpty) || (password.isEmpty)) {
            errorAlert(errorString: "Email or Password field is empty.  Please enter missing info.")
        } else {
       
        UdacityClient.sharedInstance().logInToUdacity(email: email, password: password) { (success, errorString) in
            
            if success {
               // UdacityClient.sharedInstance().getUserData(userID: self.appDelegate.userID!) { (success, errorString) in
                    
                    if success {
                        performUIUpdatesOnMain {
                        
                            self.statusWheel.isHidden = false
                            self.statusWheel.startAnimating()
                            self.completeLogin()
                        }
                    }else {
                            self.errorAlert(errorString: "Login Failed either due to incorrect Email/Password or Network issues")
                    }
                //    }
               // } else {
              //  self.errorAlert(errorString: "Error in logonviewcontroller in triangle")
           // }
            
            }
            }
        }
    }


    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        userName.resignFirstResponder()
        passWord.resignFirstResponder()
        
        return true
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        
        if passWord.isFirstResponder
        {
            return keyboardSize!.cgRectValue.height
            
        }
            
        else
        {
            return 0
            
        }
        
    }
    
    
    func keyboardWillShow(_ notification:Notification)
    {
        view.frame.origin.y = getKeyboardHeight(notification: notification as NSNotification) * (-1)
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
        view.frame.origin.y = 0
    }
    
    
    func subscribeToKeyboardNotifications()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications()
    {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
}

extension LogOnViewController: UITextViewDelegate {
    
    func errorAlert(errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
}


