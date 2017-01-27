//
//  GiftsTVC.swift
//  final
//
//  Created by Akash Ungarala on 8/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class GiftsTVC: UITableViewController {
    
    var person:Person!
    var gift:Gift!
    var gifts = [Gift]()
    var userId:String!
    var ref:FIRDatabaseReference!
    var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = FIRAuth.auth()?.currentUser {
            userId = user.uid
        }
        self.title = person.name
    }
    
    func getGifts() {
        var localArray = [Gift]()
        self.activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            var gift = Gift()
            gift.id = snapshot.key
            gift.name = snapshot.value?.objectForKey("name") as! String
            gift.price = String(snapshot.value?.objectForKey("price") as! Int)
            gift.url = snapshot.value?.objectForKey("url") as! String
            localArray.insert(gift, atIndex: 0)
            self.gifts = localArray
            self.tableView.reloadData()
            self.activityIndicatorView.stopAnimating()
        })
        self.activityIndicatorView.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getGifts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GiftCustomCell", forIndexPath: indexPath) as! GiftCustomCell
        if gifts[indexPath.row].url != nil {
            if let imageURL:NSURL? = NSURL(string: gifts[indexPath.row].url) {
                if let url = imageURL {
                    cell.avatar.sd_setImageWithURL(url)
                }
            }
        } else {
            cell.avatar.image = UIImage(named: "no_image")
        }
        cell.name.text = gifts[indexPath.row].name
        cell.price.text = "$ \(gifts[indexPath.row].price)"
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectGiftSegue" {
            let destination = segue.destinationViewController as! SelectGiftTVC
            destination.person = person
        }
    }
    
    @IBAction func cancelUnwindToGifts(sender: UIStoryboardSegue) {}
    
    @IBAction func submitUnwindToGifts(sender: UIStoryboardSegue) {
        ref.child(gift.id).setValue(["name": gift.name, "price": Int(gift.price)!, "url": gift.url])
        getGifts()
        self.tableView.reloadData()
    }

}
