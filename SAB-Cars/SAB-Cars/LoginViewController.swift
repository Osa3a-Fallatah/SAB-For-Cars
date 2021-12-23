//
//  LoginViewController.swift
//  SAB-Cars
//
//  Created by Osama folta on 07/05/1443 AH.
//
import Firebase
import FirebaseAuth
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var buttonLayout1: UIButton!
    
    @IBAction func logInButton(_ sender: UIButton) {
        logIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonLayout1.layer.cornerRadius = 10
        buttonLayout1.layer.borderWidth = 1
        self.navigationItem.leftBarButtonItems?.removeAll()
        design.chageColore(view)
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "homepage", sender: self)
        }
        
    }
    func logIn(){
        let email = emailTextField.text!
        let pass = passwordTextField.text!
        Auth.auth().signIn(withEmail:email, password:pass) { result, error in
            if error == nil {
                self.performSegue(withIdentifier: "homepage", sender: self)
            }  else {
                design.useAlert(title: "Error", message: error!.localizedDescription, vc: self)
            }
        }
    }    
}
