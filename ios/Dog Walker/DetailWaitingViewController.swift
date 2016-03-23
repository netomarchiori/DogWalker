//
//  DetailWaitingViewController.swift
//  Dog Walker
//
//  Created by Usuário Convidado on 15/03/16.
//  Copyright © 2016 FIAP. All rights reserved.
//

import UIKit
import Firebase

class DetailWaitingViewController: UIViewController {
    
    var uid: String = ""
    var schedulingId: String = ""
    let arrImage = [UIImage(named: "dog_1")!, UIImage(named: "dog_2")!]
    var counter = 600
    var timer = NSTimer()
    
    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var labelBottom: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var dogAnimation: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(uid)
        
        self.dogAnimation.animationDuration = 0.5
        self.dogAnimation.animationRepeatCount = 0
        self.dogAnimation.animationImages = self.arrImage
        self.dogAnimation.startAnimating()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerCount", userInfo: nil, repeats: true)
        startObserver()
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timerCount() {
        --counter
        self.time.text = secondsToTime(counter)
    }
    
    func secondsToTime(counter: Int) -> String {
        
        let minutes: Int = counter / 60
        let seconds: Int = counter - (minutes * 60)
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startObserver() {
        let ref = Firebase(url:"https://dog-walker-app.firebaseio.com/schedulings/\(self.schedulingId)")
        // Attach a closure to read the data at our posts reference
        ref.observeEventType(.Value, withBlock: { snapshot in
            if let schedule = snapshot.value {
                let status: String = (schedule["status"] as? String)!
                if (status.uppercaseString == "OK") {
                    self.labelHeader.text = "Passeio Confirmado!"
                    self.labelBottom.text = "Mais detalhes do passeio no histórico!"
                    self.dogAnimation.stopAnimating()
                    self.dogAnimation.image = UIImage(named: "dog_1")
                    self.labelBottom.backgroundColor = UIColor.greenColor()
                    self.timer.invalidate()
                    self.time.hidden = true
                }
            }
            }, withCancelBlock: { error in
                
        })
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
