//
//  ChristmasListTVC.swift
//  final
//
//  Created by Akash Ungarala on 8/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ChristmasListTVC: UITableViewController {
    
    var persons = [Person]()
    var gifts:[Gift]!
    var userId:String!
    let ref = FIRDatabase.database().referenceWithPath("users/").child((FIRAuth.auth()?.currentUser?.uid)!).child("persons")
    var activityIndicatorView: ActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = FIRAuth.auth()?.currentUser {
            userId = user.uid
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var localArray = [Person]()
        self.activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            var person = Person()
            person.id = snapshot.value?.objectForKey("id") as! String
            person.avatar = snapshot.value?.objectForKey("avatar") as! String
            if snapshot.value?.objectForKey("avatar") != nil {
                person.avatar = snapshot.value?.objectForKey("avatar") as! String
            }
            person.name = snapshot.value?.objectForKey("name") as! String
            person.allocatedBudget = snapshot.value?.objectForKey("allocated_budget") as! String
            person.createdAt = snapshot.value?.objectForKey("created_at") as! NSTimeInterval
            if snapshot.value?.objectForKey("gifts") != nil {
                var localArrayGifts = [Gift]()
                person.gifts = [Gift]()
                self.ref.child(person.id).child("gifts").observeEventType(.ChildAdded, withBlock: { giftSnapshot in
                    var gift = Gift()
                    gift.id = giftSnapshot.key
                    gift.name = giftSnapshot.value?.objectForKey("name") as! String
                    gift.url = giftSnapshot.value?.objectForKey("url") as! String
                    gift.price = String(giftSnapshot.value?.objectForKey("price") as! Int)
                    localArrayGifts.insert(gift, atIndex: 0)
                    person.gifts = localArrayGifts
                })
                localArray.insert(person, atIndex: 0)
                self.persons = localArray
                person.gifts = self.gifts
                self.tableView.reloadData()
                self.activityIndicatorView.stopAnimating()
            } else {
                localArray.insert(person, atIndex: 0)
                self.persons = localArray
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
        return persons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCustomCell", forIndexPath: indexPath) as! PersonCustomCell
        if persons[indexPath.row].avatar != nil {
            if let imageURL:NSURL? = NSURL(string: persons[indexPath.row].avatar) {
                if let url = imageURL {
                    cell.avatar.sd_setImageWithURL(url)
                }
            }
        } else {
            cell.avatar.image = UIImage(named: "default_avatar")
        }
        cell.name.text = persons[indexPath.row].name
        if persons[indexPath.row].gifts != nil {
            print("Gifts are present")
            cell.giftsBought.text = "\(persons[indexPath.row].gifts.count) Gifts Bought"
            var total = 0
            for gift in persons[indexPath.row].gifts {
                total = total + Int(gift.price)!
            }
            cell.spentBudget.text = "$ \(total)"
            if (total < Int(persons[indexPath.row].allocatedBudget)) {
                cell.spentBudget.textColor = UIColor(red: 20.0/255.0, green: 200.0/255.0, blue: 20.0/255.0, alpha: 0.5)
            }
        } else {
            cell.giftsBought.text = "0 Gifts Bought"
            cell.spentBudget.text = "$ 0"
            cell.spentBudget.textColor = UIColor(red: 20.0/255.0, green: 200.0/255.0, blue: 20.0/255.0, alpha: 0.5)
        }
        cell.allocatedBudget.text = "$ \(persons[indexPath.row].allocatedBudget)"
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GiftsSegue" {
            let destination = segue.destinationViewController as! GiftsTVC
            let person = persons[(self.tableView.indexPathForSelectedRow?.row)!]
            destination.person = person
            destination.ref = FIRDatabase.database().referenceWithPath("users/").child((FIRAuth.auth()?.currentUser?.uid)!).child("persons").child(person.id).child("gifts")
        }
    }
    
    @IBAction func cancelUnwindToChristmasList(sender: UIStoryboardSegue) {}
    
    @IBAction func submitUnwindToChristmasList(sender: UIStoryboardSegue) {}

}