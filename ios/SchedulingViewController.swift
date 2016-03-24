//
//  SchedulingViewController.swift
//  Dog Walker
//
//  Created by Usuário Convidado on 15/03/16.
//  Copyright © 2016 FIAP. All rights reserved.
//

import UIKit
import Firebase

class SchedulingViewController: UIViewController, LoginViewControllerDelegate {
    
    @IBOutlet weak var imagemPasseador: UIImageView!
    @IBOutlet weak var nomePasseador: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusPasseador: UILabel!
    @IBOutlet weak var iconeStatusPasseador: UIView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var dogSize: UISegmentedControl!
    
    var session: NSURLSession?
    
    var walker:User = User()
    
    let ref = Firebase(url:"https://dog-walker-app.firebaseio.com/schedulings")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nomePasseador.text = getGender(walker.gender) + " - " + walker.name
        statusPasseador.text = getStatus(walker.status)
        switch walker.status{
        case "busy":
        iconeStatusPasseador.backgroundColor = UIColor.redColor()
        case "available":
        iconeStatusPasseador.backgroundColor = UIColor.greenColor()
        case "almost":
        iconeStatusPasseador.backgroundColor = UIColor.yellowColor()
        default: break
        }
        
        self.setPickerToolbar()
        
        if let checkedUrl = NSURL(string: walker.picture) {
            downloadImage(checkedUrl)
        }
        
        print("Opa, chegou nos detalhes... \(walker.uuid) - \(walker.name)")
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
        
        if (sender.tag == 0) {
            //data Tag 0
            datePickerView.datePickerMode = UIDatePickerMode.Date
            datePickerView.tag = 0
        } else {
            //hora Tag 1
            datePickerView.datePickerMode = UIDatePickerMode.Time
            datePickerView.tag = 1
        }
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        if (sender.tag == 0) {
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            dateTextField.text = dateFormatter.stringFromDate(sender.date)
        } else {
            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            timeTextField.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    
    func setPickerToolbar(){
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        toolBar.tintColor = UIColor.whiteColor()
        toolBar.backgroundColor = UIColor.blackColor()
        //let todayBtn = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: "todayPressed:")
        //let nowBtn = UIBarButtonItem(title: "Now", style: UIBarButtonItemStyle.Plain, target: self, action: "nowPressed:")
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "donePressed:")
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 12)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.text = "Selecione a data"
        label.textAlignment = NSTextAlignment.Center
        let textBtn = UIBarButtonItem(customView: label)
        
        //let toolBar2 = toolBar
        
        //okBarBtn.tag = 0
        toolBar.setItems([flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        dateTextField.inputAccessoryView = toolBar
        timeTextField.inputAccessoryView = toolBar
        
        let okBarBtn2 = okBarBtn
        
        //toolBar2.setItems([nowBtn,flexSpace,textBtn,flexSpace,okBarBtn2], animated: true)
        //timeTextField.inputAccessoryView = toolBar2
    }
    
    func donePressed(sender: UIBarButtonItem) {
        dateTextField.resignFirstResponder()
        timeTextField.resignFirstResponder()
    }
    
    func todayPressed(sender: UIBarButtonItem) {
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateformatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateformatter.stringFromDate(NSDate())
        dateTextField.resignFirstResponder()
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
    
    @IBAction func btnConfirm(sender: UIButton) {
        if (CurrentUser.uid == "") {
            performSegueWithIdentifier("schedulingToLoginSegue", sender: sender)
        } else {
            performSegueWithIdentifier("schedulingToDetailSegue", sender: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "schedulingToLoginSegue") {
            let vc: LoginViewController = segue.destinationViewController as! LoginViewController
            vc.delegate = self
        } else if (segue.identifier == "schedulingToDetailSegue") {
            let vc: DetailWaitingViewController = segue.destinationViewController as! DetailWaitingViewController
            vc.schedulingId = "-KDVtYKunWpF4InQMc3g"
        }
    }
    
    func loginViewDismissed() {
        insertSchedule()
        self.performSegueWithIdentifier("schedulingToDetailSegue", sender: nil)
    }
    
    func insertSchedule() {
        
        var dogSizeString: String = ""
        switch (dogSize.selectedSegmentIndex) {
        case 0:
            dogSizeString = "Pequeno"
        case 1:
            dogSizeString = "Médio"
        case 2:
            dogSizeString = "Grande"
        default:
            break
        }
        
        //data e hora do pedido
        
        let schedule = ["uid": CurrentUser.uid, "walkerid": walker.uuid, "date": dateTextField.text!, "time": timeTextField.text!, "duration": duration.text!, "dog_size": dogSizeString, "status": "Pending", "request_date": "data/hora do pedido"]
        ref.childByAutoId().setValue(schedule)
    }

    /*
    * Metodo para trazer o status em portugues.
    * Pode ser evoluido para fazer internacionalizacao, talvez.
    */
    func getStatus(status: String) -> String {
        var statusPtBr = ""
        
        switch status {
        case "available":
            statusPtBr = "Disponível no momento"
        case "busy":
            statusPtBr = "Em passeio"
        case "offline":
            statusPtBr = "Não disponível"
        default:
            statusPtBr = "Opz!"
        }
        return statusPtBr
    }

    func getGender(gender: String) -> String {
        var genderPtBr = ""
        
        switch gender {
        case "male":
            genderPtBr = "Passeador"
        case "female":
            genderPtBr = "Passeadora"
        default:
            genderPtBr = "Opz!"
        }
        return genderPtBr
    }
}

