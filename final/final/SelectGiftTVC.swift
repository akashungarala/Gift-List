//
//  SelectGiftTVC.swift
//  final
//
//  Created by Akash Ungarala on 8/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class SelectGiftTVC: UITableViewController {
    
    var person:Person!
    var remainingBudget:Int!
    var gifts = [Gift]()
    var userId:String!
    let ref = FIRDatabase.database().referenceWithPath("gifts/")
    var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = FIRAuth.auth()?.currentUser {
            userId = user.uid
        }
        self.activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        var total = 0
        var localArrayGifts = [Gift]()
        let ref = FIRDatabase.database().referenceWithPath("users/").child((FIRAuth.auth()?.currentUser?.uid)!).child("persons")
        ref.child(person.id).child("gifts").observeEventType(.ChildAdded, withBlock: { giftSnapshot in
            var gift = Gift()
            gift.id = giftSnapshot.key
            gift.name = giftSnapshot.value?.objectForKey("name") as! String
            gift.url = giftSnapshot.value?.objectForKey("url") as! String
            gift.price = String(giftSnapshot.value?.objectForKey("price") as! Int)
            localArrayGifts.insert(gift, atIndex: 0)
            self.person.gifts = localArrayGifts
        })
        if person.gifts != nil {
            for gift in person.gifts {
                total = total + Int(gift.price)!
            }
        }
        remainingBudget = Int(person.allocatedBudget)! - total
        self.tableView.reloadData()
        self.activityIndicatorView.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var localArray = [Gift]()
        self.activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            if (snapshot.value?.objectForKey("price") as! Int) <= self.remainingBudget {
                var gift = Gift()
                gift.id = snapshot.key
                gift.name = snapshot.value?.objectForKey("name") as! String
                gift.price = String(snapshot.value?.objectForKey("price") as! Int)
                gift.url = snapshot.value?.objectForKey("url") as! String
                localArray.insert(gift, atIndex: 0)
                self.gifts = localArray
                self.tableView.reloadData()
                self.activityIndicatorView.stopAnimating()
            }
        })
        self.activityIndicatorView.stopAnimating()
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
        if segue.identifier == "SubmitSelectGiftSegue" {
            let destination = segue.destinationViewController as! GiftsTVC
            destination.gift = gifts[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    @IBAction func cancelUnwindToGifts(sender: UIStoryboardSegue) {}
    
    @IBAction func submitUnwindToGifts(sender: UIStoryboardSegue) {}

}
