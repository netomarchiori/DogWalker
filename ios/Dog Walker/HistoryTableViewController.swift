//
//  HistoryTableViewController.swift
//  Dog Walker
//
//  Created by Usuário Convidado on 15/03/16.
//  Copyright © 2016 FIAP. All rights reserved.
//

import UIKit
import Firebase

class HistoryTableViewController: UITableViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    let ref = Firebase(url:"https://dog-walker-app.firebaseio.com/schedulings")
    
    var schedulings: [Scheduling] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        // Attach a closure to read the data at our posts reference
        self.ref.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value)
            
            // print(snapshot.value!)
            self.loadSchedulings(snapshot.value!)
            self.tableView.reloadData()
            
            // let title = snapshot.value.objectForKey("full_name") as? String
            // self.btnDebug.setTitle(title, forState: .Normal)
            
            }, withCancelBlock: { error in
                print("erro: \(error.description)")
        })
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "doRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.tintColor = UIColor.redColor()
    }

    func doRefresh() {
        self.refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let total = self.schedulings.count
        print("total de linhas: \(total)")
        
        return total
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as! HistoryTableViewCell

        print("debug: \(self.schedulings.count)")
        let content:String = self.schedulings[indexPath.row].status
        print("conteudo: \(content)")
        
        //cell.textLabel?.text = content
        cell.imgWalker.image = UIImage(named: "dogWalker")
        cell.status.text = "Status: " + self.schedulings[indexPath.row].status
        cell.hour.text = self.schedulings[indexPath.row].date
        cell.nameWaker.text = self.schedulings[indexPath.row].status
        // outros dados...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func loadSchedulings(data: AnyObject) {
        if let json = data as? [String: AnyObject] {
            print("1");
            for list in json {
                let id:String = list.0;
                
                if let scheduling = list.1 as? [String: AnyObject] {
                    var s:Scheduling = Scheduling()
                    s.id = (id);
                    
                    print(id)
                    
                    s.date = (scheduling["date"] as? String)!
                    s.dogSize = (scheduling["dog_size"] as? String)!
                    s.duration = (scheduling["duration"] as? String)!
                    s.status = (scheduling["status"] as? String)!
                    s.time = (scheduling["time"] as? String)!
                    s.walkerId = (scheduling["walkerid"] as? String)!
                    
                    print("date: \(s.date)")
                    print("dogSize: \(s.dogSize)")
                    print("duration: \(s.duration)")
                    print("status: \(s.status)")
                    print("time: \(s.time)")
                    print("walkerid: \(s.walkerId)")
                    
                    self.schedulings.append(s)
                    print("eita: \(self.schedulings.count)")
                }
            }
        }
    }

    func getStatus(status: String) -> String {
        var statusPtBr = ""
        
        switch status {
        case "Pending":
            statusPtBr = "Pendente"
        case "Finished":
            statusPtBr = "Finalizado"
        default:
            statusPtBr = "Opz!"
        }
        
        return statusPtBr
    }

    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    // TODO
    func downloadImage(url: NSURL) -> UIImage {
        // pegar caminho de imagem...
        // https://dog-walker-app.firebaseio.com/users/-KDdv16jefncjcz4DqdV/picture.json
        var image:UIImage = UIImage(named: "dogWalker")!
        loadingIndicator.startAnimating()
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.loadingIndicator.stopAnimating()
                image = UIImage(data: data)!
            }
        }
        return image
    }
}
