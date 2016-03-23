//
//  LoginViewController.swift
//  Dog Walker
//
//  Created by Usuário Convidado on 15/03/16.
//  Copyright © 2016 FIAP. All rights reserved.
//

import UIKit
import Firebase

protocol LoginViewControllerDelegate: class {
    func loginViewDismissed()
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    weak var delegate: LoginViewControllerDelegate?
    
    let ref = Firebase(url:"https://dog-walker-app.firebaseio.com/")
    var uid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(sender: UIButton) {
        ref.createUser(tfEmail.text!, password: tfPassword.text!, withValueCompletionBlock: { error, result in
            if (error == nil) {
                self.login()
            } else {
                self.alert("Erro ao cadastrar usuário")
            }
        })
    }
    
    @IBAction func login(sender: UIButton) {
        login()
    }

    func login() {
        ref.authUser(tfEmail.text!, password: tfPassword.text!) { (error, data) -> Void in
            if (error == nil) {
                CurrentUser.uid = data.uid
                self.uid = data.uid
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.loginViewDismissed()
                //self.performSegueWithIdentifier("loginToDetailWaitingSegue", sender: nil)
            } else {
                self.alert("Usuário ou senha inválido(s)")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "loginToDetailWaitingSegue") {
            let viewController: DetailWaitingViewController = segue.destinationViewController as! DetailWaitingViewController
            viewController.uid = self.uid
        }
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: "Atenção!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
