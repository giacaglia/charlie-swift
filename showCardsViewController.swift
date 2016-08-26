//
//  showCardsViewController.swift
//  charlie
//
//  Created by Jim Caralis on 6/22/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//
import UIKit
import Realm


class showCardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var cardsTableView: UITableView!
    @IBOutlet weak var addAccountButton: UIButton!
    var accounts = realm.objects(Account)
      
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if accounts.count > 0 {
            addAccountButton.isEnabled = false
        }
        cardsTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    //for test checkin
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cardTableViewCell
        cell.cardView.layer.cornerRadius = 20
        cell.cardView.layer.borderColor = listBlue.cgColor
        cell.cardView.layer.borderWidth = 0.5
        if let current = accounts[(indexPath as NSIndexPath).row].balance!.current.value
        {
            cell.cardBalance.text = String(stringInterpolationSegment: current)
        }
        else
        {
            cell.cardBalance.text = "n/a"
        }
        cell.cardName.text = accounts[(indexPath as NSIndexPath).row].meta!.name
        cell.cardAccountNumber.text = accounts[(indexPath as NSIndexPath).row].meta!.number
        cell.accountID.text = accounts[(indexPath as NSIndexPath).row]._id
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @IBAction func dismissViewButtonPress(_ sender: UIButton ) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openLink(_ sender: UIButton) {
        if sender.tag == 0 {
            UIApplication.shared.openURL(URL(string: "http://www.charliestudios.com/terms")!)
        }
        else {
            UIApplication.shared.openURL(URL(string: "http://www.charliestudios.com/privacy")!)
        }
    }
    
}
