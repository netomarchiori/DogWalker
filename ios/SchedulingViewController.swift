//
//  SchedulingViewController.swift
//  Dog Walker
//
//  Created by Usuário Convidado on 15/03/16.
//  Copyright © 2016 FIAP. All rights reserved.
//

import UIKit

class SchedulingViewController: UIViewController {

    
    @IBOutlet weak var imagemPasseador: UIImageView!
    @IBOutlet weak var nomePasseador: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusPasseador: UILabel!
    @IBOutlet weak var iconeStatusPasseador: UIView!
    @IBOutlet weak var dateTextField: UITextField!
    
    var session: NSURLSession?
    
    var user:User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        nomePasseador.text = user.name
        statusPasseador.text = user.status
        switch user.status{
        case "busy":
        iconeStatusPasseador.backgroundColor = UIColor.redColor()
        case "available":
        iconeStatusPasseador.backgroundColor = UIColor.greenColor()
        case "almost":
        iconeStatusPasseador.backgroundColor = UIColor.yellowColor()
        default: break
        }
        
        
        if let checkedUrl = NSURL(string: user.picture) {
            downloadImage(checkedUrl)
        }
        
        print("Opa, chegou nos detalhes... \(user.uuid) - \(user.name)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func dataFieldEditing(sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL) {
        loadingIndicator.startAnimating()
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.imagemPasseador.image = UIImage(data: data)
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}

